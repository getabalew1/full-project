/*
  # Create Student Union Database Schema

  1. New Tables
    - `users`
      - `id` (uuid, primary key)
      - `name` (text, required)
      - `username` (text, unique, required) - must start with 'dbu' followed by 8 digits
      - `email` (text, unique)
      - `password_hash` (text, required)
      - `is_active` (boolean, default true)
      - `department` (text, required)
      - `year` (text, required) - academic year
      - `is_admin` (boolean, default false)
      - `role` (text, default 'student')
      - `is_locked` (boolean, default false)
      - `login_attempts` (integer, default 0)
      - `lock_until` (timestamptz)
      - `last_login` (timestamptz)
      - `profile_image` (text)
      - `student_id` (text)
      - `phone_number` (text)
      - `address` (text)
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())
    
    - `elections`
      - `id` (uuid, primary key)
      - `title` (text, required)
      - `description` (text, required)
      - `start_date` (timestamptz, required)
      - `end_date` (timestamptz, required)
      - `status` (text, default 'upcoming')
      - `election_type` (text, default 'general')
      - `total_votes` (integer, default 0)
      - `eligible_voters` (integer, default 0)
      - `is_public` (boolean, default true)
      - `results_published` (boolean, default false)
      - `published_at` (timestamptz)
      - `created_by` (uuid, references users)
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())
    
    - `candidates`
      - `id` (uuid, primary key)
      - `election_id` (uuid, references elections)
      - `user_id` (uuid, references users)
      - `name` (text, required)
      - `username` (text, required)
      - `department` (text, required)
      - `year` (text, required)
      - `position` (text, required)
      - `profile_image` (text)
      - `biography` (text)
      - `votes` (integer, default 0)
      - `created_at` (timestamptz, default now())
    
    - `votes`
      - `id` (uuid, primary key)
      - `election_id` (uuid, references elections)
      - `user_id` (uuid, references users)
      - `candidate_id` (uuid, references candidates)
      - `ip_address` (text)
      - `voted_at` (timestamptz, default now())
    
    - `clubs`
      - `id` (uuid, primary key)
      - `name` (text, unique, required)
      - `description` (text, required)
      - `category` (text, required)
      - `founded` (text, required)
      - `image` (text)
      - `status` (text, default 'pending_approval')
      - `contact_email` (text)
      - `office_location` (text)
      - `contact_phone` (text)
      - `website` (text)
      - `meeting_schedule` (text)
      - `requirements` (text)
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())
    
    - `club_members`
      - `id` (uuid, primary key)
      - `club_id` (uuid, references clubs)
      - `user_id` (uuid, references users)
      - `full_name` (text, required)
      - `department` (text, required)
      - `year` (text, required)
      - `background` (text)
      - `role` (text, default 'member')
      - `status` (text, default 'pending')
      - `joined_at` (timestamptz, default now())
    
    - `complaints`
      - `id` (uuid, primary key)
      - `case_id` (text, unique, required)
      - `title` (text, required)
      - `description` (text, required)
      - `category` (text, required)
      - `priority` (text, default 'medium')
      - `status` (text, default 'submitted')
      - `submitted_by` (uuid, references users)
      - `assigned_to` (uuid, references users)
      - `branch` (text)
      - `is_urgent` (boolean, default false)
      - `resolved_at` (timestamptz)
      - `closed_at` (timestamptz)
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())
    
    - `posts`
      - `id` (uuid, primary key)
      - `title` (text, required)
      - `content` (text, required)
      - `type` (text, default 'News')
      - `category` (text, default 'General')
      - `author_id` (uuid, references users)
      - `date` (timestamptz, default now())
      - `image` (text)
      - `location` (text)
      - `time` (text)
      - `event_date` (timestamptz)
      - `important` (boolean, default false)
      - `expiry_date` (timestamptz)
      - `status` (text, default 'published')
      - `views` (integer, default 0)
      - `is_pinned` (boolean, default false)
      - `published_at` (timestamptz)
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to read/write their own data
    - Add policies for admins to manage all data
*/

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  username text UNIQUE NOT NULL,
  email text UNIQUE,
  password_hash text NOT NULL,
  is_active boolean DEFAULT true,
  department text NOT NULL,
  year text NOT NULL,
  is_admin boolean DEFAULT false,
  role text DEFAULT 'student',
  is_locked boolean DEFAULT false,
  login_attempts integer DEFAULT 0,
  lock_until timestamptz,
  last_login timestamptz,
  profile_image text DEFAULT 'https://images.pexels.com/photos/3763188/pexels-photo-3763188.jpeg?auto=compress&cs=tinysrgb&w=400',
  student_id text,
  phone_number text,
  address text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create elections table
CREATE TABLE IF NOT EXISTS elections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  start_date timestamptz NOT NULL,
  end_date timestamptz NOT NULL,
  status text DEFAULT 'upcoming',
  election_type text DEFAULT 'general',
  total_votes integer DEFAULT 0,
  eligible_voters integer DEFAULT 0,
  is_public boolean DEFAULT true,
  results_published boolean DEFAULT false,
  published_at timestamptz,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create candidates table
CREATE TABLE IF NOT EXISTS candidates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  election_id uuid REFERENCES elections(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id),
  name text NOT NULL,
  username text NOT NULL,
  department text NOT NULL,
  year text NOT NULL,
  position text NOT NULL,
  profile_image text DEFAULT 'https://images.pexels.com/photos/3763188/pexels-photo-3763188.jpeg?auto=compress&cs=tinysrgb&w=400',
  biography text,
  votes integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create votes table
CREATE TABLE IF NOT EXISTS votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  election_id uuid REFERENCES elections(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id),
  candidate_id uuid REFERENCES candidates(id) ON DELETE CASCADE,
  ip_address text,
  voted_at timestamptz DEFAULT now(),
  UNIQUE(election_id, user_id)
);

-- Create clubs table
CREATE TABLE IF NOT EXISTS clubs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text NOT NULL,
  category text NOT NULL,
  founded text NOT NULL,
  image text DEFAULT 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=400',
  status text DEFAULT 'pending_approval',
  contact_email text,
  office_location text,
  contact_phone text,
  website text,
  meeting_schedule text,
  requirements text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create club_members table
CREATE TABLE IF NOT EXISTS club_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id uuid REFERENCES clubs(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id),
  full_name text NOT NULL,
  department text NOT NULL,
  year text NOT NULL,
  background text,
  role text DEFAULT 'member',
  status text DEFAULT 'pending',
  joined_at timestamptz DEFAULT now(),
  UNIQUE(club_id, user_id)
);

-- Create complaints table
CREATE TABLE IF NOT EXISTS complaints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id text UNIQUE NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  category text NOT NULL,
  priority text DEFAULT 'medium',
  status text DEFAULT 'submitted',
  submitted_by uuid REFERENCES users(id),
  assigned_to uuid REFERENCES users(id),
  branch text,
  is_urgent boolean DEFAULT false,
  resolved_at timestamptz,
  closed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  type text DEFAULT 'News',
  category text DEFAULT 'General',
  author_id uuid REFERENCES users(id),
  date timestamptz DEFAULT now(),
  image text,
  location text,
  time text,
  event_date timestamptz,
  important boolean DEFAULT false,
  expiry_date timestamptz,
  status text DEFAULT 'published',
  views integer DEFAULT 0,
  is_pinned boolean DEFAULT false,
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_admin ON users(is_admin);
CREATE INDEX IF NOT EXISTS idx_elections_status ON elections(status);
CREATE INDEX IF NOT EXISTS idx_elections_dates ON elections(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_candidates_election ON candidates(election_id);
CREATE INDEX IF NOT EXISTS idx_votes_election ON votes(election_id);
CREATE INDEX IF NOT EXISTS idx_votes_user ON votes(user_id);
CREATE INDEX IF NOT EXISTS idx_clubs_status ON clubs(status);
CREATE INDEX IF NOT EXISTS idx_clubs_category ON clubs(category);
CREATE INDEX IF NOT EXISTS idx_club_members_club ON club_members(club_id);
CREATE INDEX IF NOT EXISTS idx_club_members_user ON club_members(user_id);
CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_submitted_by ON complaints(submitted_by);
CREATE INDEX IF NOT EXISTS idx_posts_type ON posts(type);
CREATE INDEX IF NOT EXISTS idx_posts_date ON posts(date DESC);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE elections ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can read all user profiles"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (id = (current_setting('app.current_user_id', true))::uuid)
  WITH CHECK (id = (current_setting('app.current_user_id', true))::uuid);

-- RLS Policies for elections table
CREATE POLICY "Everyone can read public elections"
  ON elections FOR SELECT
  USING (is_public = true);

CREATE POLICY "Admins can manage elections"
  ON elections FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = (current_setting('app.current_user_id', true))::uuid
      AND is_admin = true
    )
  );

-- RLS Policies for candidates table
CREATE POLICY "Everyone can read candidates"
  ON candidates FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage candidates"
  ON candidates FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = (current_setting('app.current_user_id', true))::uuid
      AND is_admin = true
    )
  );

-- RLS Policies for votes table
CREATE POLICY "Users can read own votes"
  ON votes FOR SELECT
  USING (user_id = (current_setting('app.current_user_id', true))::uuid);

CREATE POLICY "Users can insert own votes"
  ON votes FOR INSERT
  WITH CHECK (user_id = (current_setting('app.current_user_id', true))::uuid);

-- RLS Policies for clubs table
CREATE POLICY "Everyone can read active clubs"
  ON clubs FOR SELECT
  USING (status = 'active' OR status = 'pending_approval');

CREATE POLICY "Admins can manage clubs"
  ON clubs FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = (current_setting('app.current_user_id', true))::uuid
      AND is_admin = true
    )
  );

-- RLS Policies for club_members table
CREATE POLICY "Everyone can read club members"
  ON club_members FOR SELECT
  USING (true);

CREATE POLICY "Users can join clubs"
  ON club_members FOR INSERT
  WITH CHECK (user_id = (current_setting('app.current_user_id', true))::uuid);

-- RLS Policies for complaints table
CREATE POLICY "Users can read own complaints"
  ON complaints FOR SELECT
  USING (
    submitted_by = (current_setting('app.current_user_id', true))::uuid
    OR EXISTS (
      SELECT 1 FROM users
      WHERE id = (current_setting('app.current_user_id', true))::uuid
      AND is_admin = true
    )
  );

CREATE POLICY "Users can create complaints"
  ON complaints FOR INSERT
  WITH CHECK (submitted_by = (current_setting('app.current_user_id', true))::uuid);

CREATE POLICY "Admins can manage complaints"
  ON complaints FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = (current_setting('app.current_user_id', true))::uuid
      AND is_admin = true
    )
  );

-- RLS Policies for posts table
CREATE POLICY "Everyone can read published posts"
  ON posts FOR SELECT
  USING (status = 'published');

CREATE POLICY "Admins can manage posts"
  ON posts FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = (current_setting('app.current_user_id', true))::uuid
      AND is_admin = true
    )
  );
