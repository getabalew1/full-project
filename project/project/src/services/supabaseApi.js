import { supabase } from './supabaseClient';
import bcrypt from 'bcryptjs';

class SupabaseApiService {

  setCurrentUserId(userId) {
    if (userId) {
      supabase.rpc('set_config', {
        parameter: 'app.current_user_id',
        value: userId
      });
    }
  }

  async login(credentials) {
    const { username, password } = credentials;

    const { data: users, error } = await supabase
      .from('users')
      .select('*')
      .eq('username', username)
      .maybeSingle();

    if (error || !users) {
      throw new Error('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, users.password_hash);

    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    if (users.is_locked) {
      if (users.lock_until && new Date(users.lock_until) > new Date()) {
        throw new Error('Account is locked. Please try again later.');
      }
      await supabase
        .from('users')
        .update({ is_locked: false, login_attempts: 0, lock_until: null })
        .eq('id', users.id);
    }

    await supabase
      .from('users')
      .update({
        last_login: new Date().toISOString(),
        login_attempts: 0
      })
      .eq('id', users.id);

    this.setCurrentUserId(users.id);

    const { password_hash, ...userWithoutPassword } = users;

    return {
      user: userWithoutPassword,
      token: users.id
    };
  }

  async register(userData) {
    const { username, password, name, department, year, phoneNumber, email } = userData;

    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('username', username)
      .maybeSingle();

    if (existingUser) {
      throw new Error('Username already exists');
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const { data: newUser, error } = await supabase
      .from('users')
      .insert({
        username,
        password_hash: passwordHash,
        name,
        department,
        year,
        phone_number: phoneNumber,
        email,
        is_admin: false,
        role: 'student'
      })
      .select()
      .single();

    if (error) {
      throw new Error(error.message || 'Registration failed');
    }

    const { password_hash, ...userWithoutPassword } = newUser;

    return {
      user: userWithoutPassword,
      token: newUser.id
    };
  }

  async getDashboardStats() {
    const activeStudentsQuery = supabase
      .from('users')
      .select('id', { count: 'exact', head: true })
      .eq('is_active', true)
      .eq('role', 'student');

    const ongoingElectionsQuery = supabase
      .from('elections')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'active');

    const activeClubsQuery = supabase
      .from('clubs')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'active');

    const pendingComplaintsQuery = supabase
      .from('complaints')
      .select('id', { count: 'exact', head: true })
      .in('status', ['submitted', 'under_review']);

    const [activeStudents, ongoingElections, activeClubs, pendingComplaints] = await Promise.all([
      activeStudentsQuery,
      ongoingElectionsQuery,
      activeClubsQuery,
      pendingComplaintsQuery
    ]);

    return {
      activeStudents: activeStudents.count || 0,
      ongoingElections: ongoingElections.count || 0,
      activeClubs: activeClubs.count || 0,
      pendingComplaints: pendingComplaints.count || 0
    };
  }

  async getPosts(params = {}) {
    let query = supabase
      .from('posts')
      .select('*')
      .eq('status', 'published')
      .order('date', { ascending: false });

    if (params.limit) {
      query = query.limit(params.limit);
    }

    if (params.type) {
      query = query.eq('type', params.type);
    }

    const { data, error } = await query;

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  async getClubs(params = {}) {
    let query = supabase
      .from('clubs')
      .select('*')
      .in('status', ['active', 'pending_approval'])
      .order('created_at', { ascending: false });

    if (params.category && params.category !== 'All') {
      query = query.eq('category', params.category);
    }

    const { data, error } = await query;

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  async getElections(params = {}) {
    let query = supabase
      .from('elections')
      .select('*, candidates(*)')
      .eq('is_public', true)
      .order('start_date', { ascending: false });

    if (params.status) {
      query = query.eq('status', params.status);
    }

    const { data, error } = await query;

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  async getComplaints(userId) {
    let query = supabase
      .from('complaints')
      .select('*')
      .order('created_at', { ascending: false });

    const { data: user } = await supabase
      .from('users')
      .select('is_admin')
      .eq('id', userId)
      .maybeSingle();

    if (!user || !user.is_admin) {
      query = query.eq('submitted_by', userId);
    }

    const { data, error } = await query;

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  async createComplaint(complaintData, userId) {
    const caseId = this.generateCaseId();

    const { data, error } = await supabase
      .from('complaints')
      .insert({
        ...complaintData,
        case_id: caseId,
        submitted_by: userId
      })
      .select()
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  generateCaseId() {
    const date = new Date();
    const formattedDate = date.toISOString().split('T')[0].replace(/-/g, '');
    const randomNum = Math.floor(Math.random() * 10000);
    return `CASE-${formattedDate}-${randomNum}`;
  }
}

export const supabaseApiService = new SupabaseApiService();
