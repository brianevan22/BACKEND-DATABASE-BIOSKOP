<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    protected string $table = 'users';

    protected function pk(): string
    {
        // Deteksi nama primary key yang umum (prioritaskan id_users)
        if (Schema::hasColumn($this->table, 'id_users')) return 'id_users';
        if (Schema::hasColumn($this->table, 'id')) return 'id';
        if (Schema::hasColumn($this->table, 'user_id')) return 'user_id';
        return 'id';
    }

    protected function hasCol(string $col): bool
    {
        try { return Schema::hasColumn($this->table, $col); }
        catch (\Throwable $e) { return false; }
    }

    /**
     * Sync customer table according to user id and role:
     * - jika $role == 'customer' -> pastikan ada record di tabel customer dengan customer_id == $userId
     *   gunakan $name/$email/$noHp bila diberikan (fallback ke users table)
     * - jika $role == 'admin' -> hapus record customer dengan id tersebut (jika ada)
     */
    protected function syncCustomer(int $userId, string $role, ?string $name = null, ?string $email = null, ?string $noHp = null): void
    {
        // only operate if table customer exists
        if (!Schema::hasTable('customer')) return;

        $pk = 'customer_id';
        // normalize data from users table if missing
        $userRow = DB::table($this->table)->where($this->pk(), $userId)->first();

        $name = $name ?? ($userRow->name ?? null);
        // email & no_hp might not exist on users table; if users has email column, try read
        if ($email === null && Schema::hasColumn($this->table, 'email')) {
            $email = $userRow->email ?? null;
        }

        if ($role === 'customer') {
            $exists = DB::table('customer')->where($pk, $userId)->exists();
            if (!$exists) {
                $insert = [$pk => $userId];
                if (Schema::hasColumn('customer','nama') && $name) $insert['nama'] = $name;
                if (Schema::hasColumn('customer','email') && $email) $insert['email'] = $email;
                if (Schema::hasColumn('customer','no_hp') && $noHp) $insert['no_hp'] = $noHp;
                if (Schema::hasColumn('customer','created_at')) $insert['created_at'] = now();
                if (Schema::hasColumn('customer','updated_at')) $insert['updated_at'] = now();
                try {
                    DB::table('customer')->insert($insert);
                } catch (\Throwable $e) {
                    try {
                        table_insert_with_pk('customer', $insert);
                    } catch (\Throwable $_) {
                        // ignore
                    }
                }
            } else {
                // Update existing customer with provided personal fields (optional)
                $upd = [];
                if (Schema::hasColumn('customer','nama') && $name) $upd['nama'] = $name;
                if (Schema::hasColumn('customer','email') && $email) $upd['email'] = $email;
                if (Schema::hasColumn('customer','no_hp') && $noHp) $upd['no_hp'] = $noHp;
                if (!empty($upd)) {
                    if (Schema::hasColumn('customer','updated_at')) $upd['updated_at'] = now();
                    DB::table('customer')->where($pk, $userId)->update($upd);
                }
            }
        } else {
            // role != customer => remove customer row if exists
            DB::table('customer')->where($pk, $userId)->delete();
        }
    }

    /**
     * GET /api/users?search=&per_page=
     */
    public function index(Request $r)
    {
        $perPage = (int) ($r->query('per_page', 15));
        $perPage = $perPage > 0 ? $perPage : 15;

        $q = DB::table($this->table);

        if ($search = $r->query('search')) {
            $q->when($this->hasCol('username'), fn($qq) => $qq->orWhere('username', 'like', "%$search%"))
              ->when($this->hasCol('email'),    fn($qq) => $qq->orWhere('email', 'like', "%$search%"))
              ->when($this->hasCol('name'),     fn($qq) => $qq->orWhere('name', 'like', "%$search%"))
              ->when($this->hasCol('nama'),     fn($qq) => $qq->orWhere('nama', 'like', "%$search%"));
        }

        return $q->orderBy($this->pk(), 'desc')->paginate($perPage);
    }

    /**
     * GET /api/users/{id}
     */
    public function show($id)
    {
        $row = DB::table($this->table)->where($this->pk(), $id)->first();
        if (!$row) return response()->json(['message' => 'Not found'], 404);
        return response()->json($row);
    }

    /**
     * POST /api/users
     * body: { username(required), password(required), email(optional), name(optional) }
     * Extended: create customer row with same id if role=customer (or default)
     */
    public function store(Request $r)
    {
        $rules = [
            'username' => ['required', 'string', Rule::unique($this->table, 'username')],
            'password' => ['required', 'string', 'min:4'],
            'email'    => ['nullable', 'email', Rule::unique($this->table, 'email')],
            'name'     => ['nullable', 'string'],
            'role'     => ['nullable', 'string', Rule::in(['admin','customer'])],
            'no_hp'    => ['nullable', 'string'],
        ];
        $r->validate($rules);

        $data = [];
        if ($this->hasCol('username')) $data['username'] = $r->input('username');
        if ($this->hasCol('email')   && $r->filled('email')) $data['email'] = $r->input('email');
        if ($this->hasCol('name')    && $r->filled('name'))  $data['name']  = $r->input('name');
        if ($this->hasCol('password')) $data['password'] = Hash::make($r->input('password'));
        // role default customer unless provided and allowed
        if ($this->hasCol('role')) $data['role'] = $r->input('role', 'customer');
        if ($this->hasCol('created_at')) $data['created_at'] = now();
        if ($this->hasCol('updated_at')) $data['updated_at'] = now();

        $id = DB::table($this->table)->insertGetId($data);
        // Sinkron ke tabel customer bila role customer
        $role = $data['role'] ?? 'customer';
        $this->syncCustomer($id, $role, $r->input('name'), $r->input('email'), $r->input('no_hp'));

        $row = DB::table($this->table)->where($this->pk(), $id)->first();
        return response()->json($row, 201);
    }

    /**
     * PUT /api/users/{id}
     */
    public function update(Request $r, $id)
    {
        $rules = [
            'username' => ['nullable', 'string', Rule::unique($this->table, 'username')->ignore($id, $this->pk())],
            'email'    => ['nullable', 'email', Rule::unique($this->table, 'email')->ignore($id, $this->pk())],
            'name'     => ['nullable', 'string'],
            'password' => ['nullable', 'string', 'min:4'],
            'role'     => ['nullable', 'string', Rule::in(['admin','customer'])],
            'no_hp'    => ['nullable', 'string'],
        ];
        $r->validate($rules);

        $data = [];
        if ($this->hasCol('username') && $r->filled('username')) $data['username'] = $r->input('username');
        if ($this->hasCol('email')    && $r->filled('email'))    $data['email']    = $r->input('email');
        if ($this->hasCol('name')     && $r->filled('name'))     $data['name']     = $r->input('name');
        if ($this->hasCol('nama')     && $r->filled('name'))     $data['nama']     = $r->input('name');
        if ($this->hasCol('password') && $r->filled('password')) $data['password'] = Hash::make($r->input('password'));
        if ($this->hasCol('role') && $r->filled('role')) $data['role'] = $r->input('role');
        if ($this->hasCol('updated_at')) $data['updated_at'] = now();

        if ($data) {
            DB::table($this->table)->where($this->pk(), $id)->update($data);
        }

        // Setelah update, sinkron ke customer sesuai role (hapus/restore)
        $fresh = DB::table($this->table)->where($this->pk(), $id)->first();
        $role = ($fresh->role ?? 'customer');
        $this->syncCustomer(
            (int)$id,
            $role,
            $r->filled('name') ? $r->input('name') : ($fresh->name ?? null),
            $r->filled('email') ? $r->input('email') : (Schema::hasColumn($this->table,'email') ? ($fresh->email ?? null) : null),
            $r->filled('no_hp') ? $r->input('no_hp') : null
        );

        $row = DB::table($this->table)->where($this->pk(), $id)->first();
        if (!$row) return response()->json(['message' => 'Not found'], 404);
        return response()->json($row);
    }

    /**
     * DELETE /api/users/{id}
     */
    public function destroy($id)
    {
        // delete related customer row first (if any) — gunakan kolom link id_users di customer jika ada
        if (Schema::hasTable('customer')) {
            $custLink = Schema::hasColumn('customer','id_users') ? 'id_users' : 'customer_id';
            DB::table('customer')->where($custLink, (int)$id)->delete();
        }
        $deleted = DB::table($this->table)->where($this->pk(), $id)->delete();
        return response()->json(['deleted' => (bool) $deleted]);
    }
}
