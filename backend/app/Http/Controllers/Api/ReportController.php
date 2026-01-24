<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\DailyStock;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function sales(Request $request)
    {
        $from = $request->query('from', now()->startOfDay()->toDateString());
        $to = $request->query('to', now()->endOfDay()->toDateString());

        $summary = Order::whereBetween('created_at', [$from, $to])
            ->select(
                DB::raw('COUNT(*) as orders'),
                DB::raw('SUM(total) as revenue'),
                DB::raw('SUM(subtotal) as subtotal')
            )
            ->first();

        $byStatus = Order::whereBetween('created_at', [$from, $to])
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get();

        return [
            'from' => $from,
            'to' => $to,
            'summary' => $summary,
            'by_status' => $byStatus,
        ];
    }

    public function dailyStock(Request $request)
    {
        $date = $request->query('date', now()->toDateString());
        return DailyStock::with('product')
            ->where('date', $date)
            ->get();
    }
}
