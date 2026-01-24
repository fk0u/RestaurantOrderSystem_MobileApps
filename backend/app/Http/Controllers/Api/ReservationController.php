<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reservation;
use Illuminate\Http\Request;

class ReservationController extends Controller
{
    public function index()
    {
        return Reservation::with(['table', 'user'])->orderByDesc('reserved_at')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'table_id' => 'nullable|exists:restaurant_tables,id',
            'party_size' => 'required|integer|min:1',
            'reserved_at' => 'required|date',
            'status' => 'nullable|string',
            'note' => 'nullable|string',
        ]);

        return Reservation::create($data);
    }

    public function update(Request $request, Reservation $reservation)
    {
        $data = $request->validate([
            'table_id' => 'nullable|exists:restaurant_tables,id',
            'party_size' => 'nullable|integer|min:1',
            'reserved_at' => 'nullable|date',
            'status' => 'nullable|string',
            'note' => 'nullable|string',
        ]);

        $reservation->update($data);
        return $reservation->refresh();
    }
}
