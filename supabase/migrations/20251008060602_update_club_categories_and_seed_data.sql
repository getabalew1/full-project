/*
  # Update Club Categories and Seed Initial Data

  1. Changes
    - Remove 'Religious' from club category enum
    - Add seed data for initial users, clubs, and posts

  2. Seed Data
    - Create admin user (dbu10101030)
    - Create sample student users
    - Create sample clubs (excluding religious category)
    - Create sample announcements/posts
*/

-- Update any existing clubs with 'Religious' category to 'Cultural'
UPDATE clubs SET category = 'Cultural' WHERE category = 'Religious';

-- Create admin user
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'dbu10101030') THEN
    INSERT INTO users (
      username,
      password_hash,
      name,
      department,
      year,
      is_admin,
      role,
      email,
      phone_number,
      is_active
    ) VALUES (
      'dbu10101030',
      '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5jtJ3PvHzC7JG',
      'System Administrator',
      'Administration',
      '1st Year',
      true,
      'admin',
      'admin@dbu.edu.et',
      '+251-911-000000',
      true
    );
  END IF;
END $$;

-- Create sample student users
DO $$
DECLARE
  user1_id uuid;
  user2_id uuid;
  user3_id uuid;
BEGIN
  -- Student 1
  IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'dbu10301001') THEN
    INSERT INTO users (
      username,
      password_hash,
      name,
      department,
      year,
      is_admin,
      role,
      email,
      phone_number,
      is_active
    ) VALUES (
      'dbu10301001',
      '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5jtJ3PvHzC7JG',
      'Abebe Kebede',
      'Computer Science',
      '3rd Year',
      false,
      'student',
      'abebe.kebede@dbu.edu.et',
      '+251-911-111111',
      true
    ) RETURNING id INTO user1_id;
  ELSE
    SELECT id INTO user1_id FROM users WHERE username = 'dbu10301001';
  END IF;

  -- Student 2
  IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'dbu10301002') THEN
    INSERT INTO users (
      username,
      password_hash,
      name,
      department,
      year,
      is_admin,
      role,
      email,
      phone_number,
      is_active
    ) VALUES (
      'dbu10301002',
      '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5jtJ3PvHzC7JG',
      'Chaltu Tadesse',
      'Engineering',
      '2nd Year',
      false,
      'student',
      'chaltu.tadesse@dbu.edu.et',
      '+251-911-222222',
      true
    ) RETURNING id INTO user2_id;
  ELSE
    SELECT id INTO user2_id FROM users WHERE username = 'dbu10301002';
  END IF;

  -- Student 3
  IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'dbu10301003') THEN
    INSERT INTO users (
      username,
      password_hash,
      name,
      department,
      year,
      is_admin,
      role,
      email,
      phone_number,
      is_active
    ) VALUES (
      'dbu10301003',
      '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5jtJ3PvHzC7JG',
      'Dawit Alemu',
      'Business',
      '4th Year',
      false,
      'student',
      'dawit.alemu@dbu.edu.et',
      '+251-911-333333',
      true
    ) RETURNING id INTO user3_id;
  ELSE
    SELECT id INTO user3_id FROM users WHERE username = 'dbu10301003';
  END IF;

  -- Create sample clubs
  IF NOT EXISTS (SELECT 1 FROM clubs WHERE name = 'Computer Science Club') THEN
    INSERT INTO clubs (
      name,
      description,
      category,
      founded,
      status,
      contact_email,
      contact_phone,
      office_location,
      meeting_schedule
    ) VALUES
    (
      'Computer Science Club',
      'A community for computer science enthusiasts to learn, share knowledge, and work on exciting tech projects together.',
      'Technology',
      '2020',
      'active',
      'csclub@dbu.edu.et',
      '+251-911-444444',
      'Building A, Room 205',
      'Every Friday at 3:00 PM'
    ),
    (
      'Drama and Arts Club',
      'Express yourself through theater, drama, and performing arts. Join us for creative workshops and performances.',
      'Arts',
      '2018',
      'active',
      'drama@dbu.edu.et',
      '+251-911-555555',
      'Cultural Center',
      'Tuesdays and Thursdays at 4:00 PM'
    ),
    (
      'Football Club',
      'For football lovers! Practice, compete, and represent DBU in inter-university tournaments.',
      'Sports',
      '2015',
      'active',
      'football@dbu.edu.et',
      '+251-911-666666',
      'Sports Complex',
      'Daily at 5:00 PM'
    ),
    (
      'Debate Society',
      'Sharpen your critical thinking and public speaking skills through structured debates and discussions.',
      'Academic',
      '2019',
      'active',
      'debate@dbu.edu.et',
      '+251-911-777777',
      'Building B, Room 301',
      'Wednesdays at 2:00 PM'
    ),
    (
      'Community Service Club',
      'Make a difference in the community through volunteer work and social outreach programs.',
      'Service',
      '2021',
      'active',
      'service@dbu.edu.et',
      '+251-911-888888',
      'Student Union Office',
      'Saturdays at 10:00 AM'
    );
  END IF;

  -- Create sample announcements
  IF NOT EXISTS (SELECT 1 FROM posts WHERE title = 'Welcome to the New Academic Year 2024') THEN
    INSERT INTO posts (
      title,
      content,
      type,
      category,
      author_id,
      important,
      status,
      published_at
    ) VALUES
    (
      'Welcome to the New Academic Year 2024',
      'Welcome to all new and returning students! We are excited to begin this academic year with you. The Student Union is here to support you throughout your journey at DBU.',
      'Announcement',
      'General',
      (SELECT id FROM users WHERE username = 'dbu10101030' LIMIT 1),
      true,
      'published',
      now()
    ),
    (
      'Annual Cultural Festival Registration Now Open',
      'Get ready for the biggest event of the year! The Annual Cultural Festival will showcase the diversity and talent of our student body. Register your club or individual performance by the end of this month.',
      'Announcement',
      'Cultural',
      (SELECT id FROM users WHERE username = 'dbu10101030' LIMIT 1),
      false,
      'published',
      now()
    ),
    (
      'New Club Registration Guidelines',
      'Are you interested in starting a new student club? We have updated our club registration guidelines to make the process easier. Visit the Student Union office for more information.',
      'Announcement',
      'Campus',
      (SELECT id FROM users WHERE username = 'dbu10101030' LIMIT 1),
      false,
      'published',
      now()
    );
  END IF;
END $$;
