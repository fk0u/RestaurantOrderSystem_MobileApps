<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->query('user_id');
        $query = Notification::query();
        if ($userId) {
            $query->where('user_id', $userId);
        }
        return $query->orderByDesc('created_at')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'title' => 'required|string',
            'body' => 'required|string',
            'channel' => 'nullable|string',
            'data' => 'nullable|array',
        ]);

        return Notification::create($data);
    }

    public function markRead(Notification $notification)
    {
        $notification->update(['is_read' => true]);
        return $notification->refresh();
    }
}
