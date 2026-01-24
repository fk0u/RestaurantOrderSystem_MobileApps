<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\RestaurantTable;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class RestoSeeder extends Seeder
{
    public function run(): void
    {
        $roles = collect(['admin', 'cashier', 'kitchen', 'customer'])->map(function ($name) {
            return Role::firstOrCreate(['name' => $name]);
        });

        User::firstOrCreate(
            ['email' => 'admin@resto.com'],
            ['name' => 'Admin Super', 'password' => Hash::make('admin123'), 'role_id' => $roles[0]->id]
        );
        User::firstOrCreate(
            ['email' => 'cashier@resto.com'],
            ['name' => 'Kasir Utama', 'password' => Hash::make('cashier123'), 'role_id' => $roles[1]->id]
        );
        User::firstOrCreate(
            ['email' => 'kitchen@resto.com'],
            ['name' => 'Chef Juna', 'password' => Hash::make('kitchen123'), 'role_id' => $roles[2]->id]
        );
        User::firstOrCreate(
            ['email' => 'user@gmail.com'],
            ['name' => 'Pelanggan Demo', 'password' => Hash::make('user123'), 'role_id' => $roles[3]->id]
        );

        for ($i = 1; $i <= 10; $i++) {
            RestaurantTable::firstOrCreate([
                'number' => 'T' . str_pad((string) $i, 2, '0', STR_PAD_LEFT)
            ], [
                'capacity' => $i <= 5 ? 4 : 2,
                'status' => 'available',
            ]);
        }

        $catFood = Category::firstOrCreate(['name' => 'makanan']);
        $catDrink = Category::firstOrCreate(['name' => 'minuman']);

        Product::firstOrCreate(['name' => 'Nasi Goreng Spesial'], [
            'category_id' => $catFood->id,
            'description' => 'Nasi goreng dengan telur, ayam, dan udang.',
            'price' => 25000,
            'image_url' => 'https://images.unsplash.com/photo-1512058564366-18510be2db19',
            'calories' => 450,
            'stock' => 50,
        ]);

        Product::firstOrCreate(['name' => 'Es Teh Manis'], [
            'category_id' => $catDrink->id,
            'description' => 'Teh manis segar dengan es batu.',
            'price' => 5000,
            'image_url' => 'https://images.unsplash.com/photo-1556679343-c7306c1976bc',
            'calories' => 120,
            'stock' => 100,
        ]);
    }
}
