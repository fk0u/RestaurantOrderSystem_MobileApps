<?php

namespace App\Http\Controllers\Api;

use App\Events\OrderReady;
use App\Http\Controllers\Controller;
use App\Models\DailyStock;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function index()
    {
        return Order::with(['items', 'table', 'user'])->orderByDesc('created_at')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'order_type' => 'required|in:dine_in,takeaway',
            'table_id' => 'nullable|exists:restaurant_tables,id',
            'table_number' => 'nullable|string',
            'table_capacity' => 'nullable|integer',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.note' => 'nullable|string',
            'items.*.modifiers' => 'nullable|array',
        ]);

        return DB::transaction(function () use ($data) {
            $todayStart = now()->startOfDay();
            $queueNumber = Order::where('order_type', $data['order_type'])
                ->where('created_at', '>=', $todayStart)
                ->count() + 1;

            $orderId = (string) Str::uuid();

            $subtotal = 0;
            foreach ($data['items'] as $item) {
                $product = Product::lockForUpdate()->findOrFail($item['product_id']);
                if ($product->stock < $item['quantity']) {
                    abort(422, "Stok tidak cukup untuk {$product->name}");
                }
                $subtotal += $product->price * $item['quantity'];
                $product->decrement('stock', $item['quantity']);

                StockMovement::create([
                    'product_id' => $product->id,
                    'type' => 'out',
                    'quantity' => $item['quantity'],
                    'reason' => 'order',
                    'created_by' => $data['user_id'] ?? null,
                ]);

                $daily = DailyStock::firstOrCreate([
                    'product_id' => $product->id,
                    'date' => now()->toDateString(),
                ], [
                    'opening_stock' => $product->stock + $item['quantity'],
                ]);
                $daily->increment('sold', $item['quantity']);
                $daily->update([
                    'closing_stock' => $product->stock,
                ]);
            }

            $tax = $subtotal * 0.11;
            $service = $subtotal * 0.05;
            $total = $subtotal + $tax + $service;

            $order = Order::create([
                'id' => $orderId,
                'user_id' => $data['user_id'] ?? null,
                'order_type' => $data['order_type'],
                'table_id' => $data['table_id'] ?? null,
                'table_number' => $data['table_number'] ?? null,
                'table_capacity' => $data['table_capacity'] ?? null,
                'queue_number' => $queueNumber,
                'status' => 'Sedang Diproses',
                'subtotal' => $subtotal,
                'tax' => $tax,
                'service' => $service,
                'total' => $total,
                'ready_at' => now()->addMinutes(20),
            ]);

            foreach ($data['items'] as $item) {
                $product = Product::findOrFail($item['product_id']);
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'product_price' => $product->price,
                    'quantity' => $item['quantity'],
                    'note' => $item['note'] ?? null,
                    'modifiers' => $item['modifiers'] ?? null,
                ]);
            }

            return $order->load('items');
        });
    }

    public function updateStatus(Request $request, Order $order)
    {
        $data = $request->validate([
            'status' => 'required|string',
            'ready_at' => 'nullable|date',
        ]);

        $order->update([
            'status' => $data['status'],
            'ready_at' => $data['ready_at'] ?? ($data['status'] === 'Siap Saji' ? now() : null),
        ]);

        if ($order->status === 'Siap Saji') {
            broadcast(new OrderReady($order));
        }

        return $order->refresh();
    }
}
