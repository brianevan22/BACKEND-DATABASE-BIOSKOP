<?php

namespace App\Http\Controllers\Api;

use App\Models\Customer;
use App\Http\Resources\CustomerResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB; // <-- tambahkan
use Illuminate\Support\Facades\Schema; // <-- tambahkan

class CustomerController extends \App\Http\Controllers\Controller
{
    public function index(Request $request)
    {
        $q = $request->query('search');
        $per = (int)($request->query('per_page', 15));
        $data = Customer::query()
            ->when($q, function($builder) use ($q) {
                $builder->where('nama', 'like', "%$q%");
                $builder->orWhere('email', 'like', "%$q%");
            })
            ->paginate($per);
        return CustomerResource::collection($data);
    }

    public function show($id)
    {
        $row = Customer::findOrFail($id);
        return new CustomerResource($row);
    }

    public function store(Request $request)
    {
        $payload = $request->all();
        $row = Customer::create($payload);
        return response()->json(new CustomerResource($row), 201);
    }

    public function update(Request $request, $id)
    {
        $row = Customer::findOrFail($id);
        $row->fill($request->all())->save();
        return new CustomerResource($row);
    }

    public function destroy($id)
    {
        // sinkron: jika ada user dengan id_users == customer id (link), hapus juga
        try {
            if (Schema::hasTable('users')) {
                // tentukan PK users (id_users atau id)
                $userPk = Schema::hasColumn('users','id_users') ? 'id_users' : (Schema::hasColumn('users','id') ? 'id' : 'id_users');
                DB::table('users')->where($userPk, (int)$id)->delete();
            }
        } catch (\Throwable $_) {
            // jangan batalkan; hanya mencoba sinkron
        }

        $row = Customer::findOrFail($id);
        $row->delete();
        return response()->json(['deleted' => true]);
    }
}
