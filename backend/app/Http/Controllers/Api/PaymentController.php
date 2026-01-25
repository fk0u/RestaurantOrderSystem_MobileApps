<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Payment;
use App\Models\Notification;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function store(Request $request, Order $order)
    {
        $data = $request->validate([
            'method' => 'required|in:cash,qris',
            'amount' => 'nullable|numeric|min:0',
            'status' => 'nullable|string',
            'reference' => 'nullable|string',
        ]);

        $amount = $data['amount'] ?? $order->total;

        $payment = Payment::updateOrCreate(
            ['order_id' => $order->id],
            [
                'method' => $data['method'],
                'amount' => $amount,
                'status' => $data['status'] ?? 'paid',
                'paid_at' => now(),
                'reference' => $data['reference'] ?? null,
            ]
        );

        Notification::create([
            'user_id' => $order->user_id,
            'title' => 'Pembayaran berhasil',
            'body' => "Pembayaran untuk pesanan {$order->id} sebesar {$amount} berhasil.",
            'channel' => 'payment',
            'data' => [
                'order_id' => $order->id,
                'amount' => $amount,
                'method' => $data['method'],
            ],
        ]);

        return $payment->refresh();
    }
}
