<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DailyStock extends Model
{
    protected $fillable = [
        'product_id',
        'date',
        'opening_stock',
        'closing_stock',
        'sold',
        'adjusted',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
