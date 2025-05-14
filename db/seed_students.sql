-- Delete existing users if they exist
DELETE FROM student_profiles WHERE user_id IN (
  SELECT id FROM users WHERE email IN (
    'f219001@cfd.nu.edu.pk', 'f219002@cfd.nu.edu.pk', 'f219003@cfd.nu.edu.pk',
    'f219004@cfd.nu.edu.pk', 'f219005@cfd.nu.edu.pk', 'f219006@cfd.nu.edu.pk',
    'f219007@cfd.nu.edu.pk', 'f219008@cfd.nu.edu.pk', 'f219009@cfd.nu.edu.pk',
    'f219010@cfd.nu.edu.pk'
  )
);

DELETE FROM users WHERE email IN (
  'f219001@cfd.nu.edu.pk', 'f219002@cfd.nu.edu.pk', 'f219003@cfd.nu.edu.pk',
  'f219004@cfd.nu.edu.pk', 'f219005@cfd.nu.edu.pk', 'f219006@cfd.nu.edu.pk',
  'f219007@cfd.nu.edu.pk', 'f219008@cfd.nu.edu.pk', 'f219009@cfd.nu.edu.pk',
  'f219010@cfd.nu.edu.pk'
);

-- Insert the users
-- All users have password: password123
-- The encrypted password is a valid bcrypt hash
INSERT INTO users (full_name, email, encrypted_password, user_type, confirmed_at, created_at, updated_at)
VALUES
('Ali Ahmed', 'f219001@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Sara Khan', 'f219002@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Usman Malik', 'f219003@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Fatima Zahra', 'f219004@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Hassan Raza', 'f219005@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Ayesha Tariq', 'f219006@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Bilal Hassan', 'f219007@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Zainab Ali', 'f219008@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Omar Farooq', 'f219009@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW()),
('Maryam Nawaz', 'f219010@cfd.nu.edu.pk', '$2a$12$kpfqEYtFyJbGJmg0YvEeXeNx.vQhx/YuSz5F/BO4hKplVzxy/IpJW', 'student', NOW(), NOW(), NOW());

-- Create student profiles for each user
INSERT INTO student_profiles (user_id, email_personal, phone_number, created_at, updated_at)
VALUES
((SELECT id FROM users WHERE email = 'f219001@cfd.nu.edu.pk'), 'personal_f219001@gmail.com', '+923001234123', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219002@cfd.nu.edu.pk'), 'personal_f219002@gmail.com', '+923001234234', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219003@cfd.nu.edu.pk'), 'personal_f219003@gmail.com', '+923001234345', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219004@cfd.nu.edu.pk'), 'personal_f219004@gmail.com', '+923001234456', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219005@cfd.nu.edu.pk'), 'personal_f219005@gmail.com', '+923001234567', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219006@cfd.nu.edu.pk'), 'personal_f219006@gmail.com', '+923001234678', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219007@cfd.nu.edu.pk'), 'personal_f219007@gmail.com', '+923001234789', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219008@cfd.nu.edu.pk'), 'personal_f219008@gmail.com', '+923001234890', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219009@cfd.nu.edu.pk'), 'personal_f219009@gmail.com', '+923001234901', NOW(), NOW()),
((SELECT id FROM users WHERE email = 'f219010@cfd.nu.edu.pk'), 'personal_f219010@gmail.com', '+923001234012', NOW(), NOW()); 