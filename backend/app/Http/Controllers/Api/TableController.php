<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RestaurantTable;
use Illuminate\Http\Request;

class TableController extends Controller
{
    public function index()
    {
        return RestaurantTable::orderBy('number')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'number' => 'required|string|unique:restaurant_tables,number',
            'capacity' => 'required|integer|min:1',
            'status' => 'nullable|string',
            'area' => 'nullable|string',
            'x' => 'nullable|numeric',
            'y' => 'nullable|numeric',
        ]);

        return RestaurantTable::create($data);
    }

    public function update(Request $request, RestaurantTable $table)
    {
        $data = $request->validate([
            'number' => 'nullable|string|unique:restaurant_tables,number,' . $table->id,
            'capacity' => 'nullable|integer|min:1',
            'status' => 'nullable|string',
            'area' => 'nullable|string',
            'x' => 'nullable|numeric',
            'y' => 'nullable|numeric',
        ]);

        $table->update($data);
        return $table->refresh();
    }

    public function updateStatus(Request $request, RestaurantTable $table)
    {
        $data = $request->validate([
            'status' => 'required|string',
        ]);

        $table->update(['status' => $data['status']]);
        return $table->refresh();
    }
}
