<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DailyStock;
use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Http\Request;

class StockController extends Controller
{
    public function adjust(Request $request, Product $product)
    {
        $data = $request->validate([
            'quantity' => 'required|integer',
            'reason' => 'nullable|string',
            'created_by' => 'nullable|exists:users,id',
        ]);

        $product->update([
            'stock' => max(0, $product->stock + $data['quantity']),
        ]);

        StockMovement::create([
            'product_id' => $product->id,
            'type' => $data['quantity'] >= 0 ? 'in' : 'out',
            'quantity' => abs($data['quantity']),
            'reason' => $data['reason'] ?? 'adjust',
            'created_by' => $data['created_by'] ?? null,
        ]);

        $daily = DailyStock::firstOrCreate([
            'product_id' => $product->id,
            'date' => now()->toDateString(),
        ], [
            'opening_stock' => $product->stock,
        ]);
        $daily->update([
            'closing_stock' => $product->stock,
            'adjusted' => $daily->adjusted + $data['quantity'],
        ]);

        return $product->refresh();
    }

    public function daily()
    {
        return DailyStock::with('product')->orderByDesc('date')->get();
    }
}
