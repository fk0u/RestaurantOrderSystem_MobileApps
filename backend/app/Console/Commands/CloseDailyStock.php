<?php

namespace App\Console\Commands;

use App\Models\DailyStock;
use App\Models\Product;
use Illuminate\Console\Command;

class CloseDailyStock extends Command
{
    protected $signature = 'stock:close-daily';
    protected $description = 'Finalize daily stock closing snapshot for all products.';

    public function handle(): int
    {
        $date = now()->toDateString();
        $products = Product::all();

        foreach ($products as $product) {
            $daily = DailyStock::firstOrCreate([
                'product_id' => $product->id,
                'date' => $date,
            ], [
                'opening_stock' => $product->stock,
            ]);

            $daily->update([
                'closing_stock' => $product->stock,
            ]);
        }

        $this->info('Daily stock closed.');
        return self::SUCCESS;
    }
}
