<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Shift;
use Illuminate\Http\Request;

class ShiftController extends Controller
{
    public function index()
    {
        return Shift::with('user')->orderByDesc('starts_at')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'role' => 'nullable|string',
            'starts_at' => 'required|date',
            'ends_at' => 'nullable|date',
            'status' => 'nullable|string',
        ]);

        return Shift::create($data);
    }

    public function update(Request $request, Shift $shift)
    {
        $data = $request->validate([
            'role' => 'nullable|string',
            'starts_at' => 'nullable|date',
            'ends_at' => 'nullable|date',
            'status' => 'nullable|string',
        ]);

        $shift->update($data);
        return $shift->refresh();
    }
}
