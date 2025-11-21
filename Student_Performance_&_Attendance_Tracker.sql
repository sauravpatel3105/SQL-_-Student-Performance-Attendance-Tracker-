create database Students_data;
use Students_data;

create table Departments (
department_id INT PRIMARY KEY,
department_name VARCHAR(100) NOT NULL
);

INSERT INTO Departments (department_id, department_name) VALUES
(1, 'Computer Science'),
(2, 'Electrical Engineering'),
(3, 'Business Administration');


create table  Faculty (
faculty_id INT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
phone_number VARCHAR(15),
department_id INT,
FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

INSERT INTO Faculty (faculty_id, name, email, phone_number, department_id) VALUES
(101, 'Dr. Alice Smith', 'alice.s@univ.edu', '555-1001', 1),
(102, 'Prof. Bob Johnson', 'bob.j@univ.edu', '555-1002', 1),
(103, 'Dr. Carol Lee', 'carol.l@univ.edu', '555-1003', 2),
(104, 'Dr. David Kim', NULL, '555-1004', 3);


CREATE TABLE Students (
student_id INT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
dob DATE,
gender ENUM('Male', 'Female', 'Other'),
email VARCHAR(100) UNIQUE,
phone_number VARCHAR(15),
address VARCHAR(255),
admission_date DATE,
department_id INT,
FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

INSERT INTO Students (student_id, name, dob, gender, email, phone_number, address, admission_date, department_id) VALUES
(2001, 'Ella Green', '2004-05-10', 'Female', 'ella.g@email.com', '555-2001', '404 Oak St', '2023-09-01', 1),
(2002, 'Frank White', '2003-11-20', 'Male', 'frank.w@email.com', '555-2002', '505 Pine St', '2023-09-01', 1),
(2003, 'Grace Hall', '2005-01-15', 'Female', 'grace.h@email.com', '555-2003', '606 Cedar St', '2023-09-01', 2),
(2004, 'Henry Black', '2002-08-25', 'Male', 'henry.b@email.com', '555-2004', '707 Birch St', '2023-09-01', 3);


create table  Courses (
course_id INT PRIMARY KEY,
course_name VARCHAR(100) NOT NULL,
faculty_id INT,
FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id)
);

INSERT INTO Courses (course_id, course_name, faculty_id) VALUES
(301, 'Database Systems', 101),
(302, 'Algorithms', 102),
(303, 'Circuit Analysis', 103),
(304, 'Marketing 101', 104),
(305, 'Advanced AI', NULL); 


CREATE TABLE Enrollments (
enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
enrollment_date DATE,
student_id INT NOT NULL,
course_id INT NOT NULL,
FOREIGN KEY (student_id) REFERENCES Students(student_id),
FOREIGN KEY (course_id) REFERENCES Courses(course_id),
UNIQUE (student_id, course_id)
);

INSERT INTO Enrollments (student_id, course_id, enrollment_date) VALUES
(2001, 301, '2023-09-05'), 
(2001, 302, '2023-09-05'), 
(2002, 301, '2023-09-06'), 
(2003, 303, '2023-09-06'); 

CREATE TABLE Attendance (
attendance_id INT PRIMARY KEY AUTO_INCREMENT,
attendance_date DATE NOT NULL,
status ENUM('Present', 'Absent', 'Late') NOT NULL,
student_id INT NOT NULL,
course_id INT NOT NULL,
FOREIGN KEY (student_id) REFERENCES Students(student_id),
FOREIGN KEY (course_id) REFERENCES Courses(course_id),
UNIQUE (student_id, course_id, attendance_date)
);

INSERT INTO Attendance (student_id, course_id, attendance_date, status) VALUES
(2001, 301, '2023-10-01', 'Present'),
(2001, 301, '2023-10-02', 'Present'),
(2001, 301, '2023-10-03', 'Present'),
(2001, 301, '2023-10-04', 'Absent'),
(2002, 301, '2023-10-01', 'Present'),
(2002, 301, '2023-10-02', 'Absent'),
(2002, 301, '2023-10-03', 'Absent'),
(2002, 301, '2023-10-04', 'Late');

CREATE TABLE Grades (
grade_id INT PRIMARY KEY AUTO_INCREMENT,
marks_obtained DECIMAL(5, 2),
student_id INT NOT NULL,
course_id INT NOT NULL,
FOREIGN KEY (student_id) REFERENCES Students(student_id),
FOREIGN KEY (course_id) REFERENCES Courses(course_id),
UNIQUE (student_id, course_id)
);

INSERT INTO Grades (student_id, course_id, marks_obtained) VALUES
(2001, 301, 95.00), 
(2001, 302, 80.00), 
(2002, 301, 45.00); 

## Q - 1 

select * from Students;
update students set gender = 'Male' where student_id = 2001 ;
delete from Students  where student_id = 2004 ;

## Q - 2

SELECT student_id, name
FROM Students
WHERE department_id = 1;

SELECT s.student_id, s.name, 
SUM(g.marks_obtained) AS total_marks
FROM Students s
JOIN Grades g ON s.student_id = g.student_id
GROUP BY s.student_id, s.name
ORDER BY total_marks DESC
LIMIT 10;

SELECT s.student_id, s.name,
(SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)) AS attendance_percentage
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name
HAVING attendance_percentage < 75;

## Q - 3

SELECT s.student_id, s.name
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
JOIN Grades g ON s.student_id = g.student_id
GROUP BY s.student_id, s.name
HAVING 
(SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)) < 50
AND 
MAX(CASE WHEN g.marks_obtained < 40 THEN 1 ELSE 0 END) = 1; -- Checks if at least one grade is a failing grade (<40)
   

SELECT s.student_id, s.name
FROM Students s
LEFT JOIN Grades g ON s.student_id = g.student_id
LEFT JOIN Attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name
HAVING 
MAX(g.marks_obtained) > 90 OR 
(SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) = COUNT(a.attendance_id)); 

SELECT f.faculty_id, f.name
FROM Faculty f
LEFT JOIN Courses c ON f.faculty_id = c.faculty_id
WHERE c.course_id IS NULL;

## Q - 4 

SELECT student_id, name
FROM Students
ORDER BY name ASC;


SELECT d.department_name, COUNT(s.student_id) AS total_students
FROM Departments d
JOIN Students s ON d.department_id = s.department_id
GROUP BY d.department_name
ORDER BY total_students DESC;

SELECT c.course_name, AVG(g.marks_obtained) AS average_marks
FROM Courses c
JOIN Grades g ON c.course_id = g.course_id
GROUP BY c.course_name;

## Q - 5 


SELECT AVG(attendance_percentage) AS overall_avg_attendance
FROM (
SELECT (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)) AS attendance_percentage
FROM Attendance a
GROUP BY a.student_id
) AS student_attendance;


SELECT c.course_name, MAX(g.marks_obtained) AS highest_mark, MIN(g.marks_obtained) AS lowest_mark
FROM Courses c
JOIN Grades g ON c.course_id = g.course_id
GROUP BY c.course_name;


SELECT d.department_name, COUNT(s.student_id) AS total_students
FROM Departments d
JOIN Students s ON d.department_id = s.department_id
GROUP BY d.department_name;



## Q - 6 


ALTER TABLE Enrollments
ADD CONSTRAINT PK_Enrollment UNIQUE (student_id, course_id);


ALTER TABLE Courses
ADD CONSTRAINT FK_Course_Faculty
FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id);


## Q - 7 

SELECT s.name, s.email, d.department_name
FROM Students s
INNER JOIN Departments d ON s.department_id = d.department_id;

SELECT s.student_id, s.name
FROM Students s
LEFT JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;

SELECT c.course_name
FROM Faculty f
RIGHT JOIN Courses c ON f.faculty_id = c.faculty_id
WHERE f.faculty_id IS NULL;


SELECT s.student_id, s.name
FROM Students s
LEFT JOIN Grades g ON s.student_id = g.student_id
WHERE g.grade_id IS NULL
UNION
SELECT s.student_id, s.name
FROM Students s
RIGHT JOIN Grades g ON s.student_id = g.student_id 
WHERE s.student_id IS NULL;


SELECT s.student_id, s.name
FROM Students s
LEFT JOIN Grades g ON s.student_id = g.student_id
WHERE g.grade_id IS NULL;

## Q - 8 

SELECT s.student_id, s.name, g.marks_obtained
FROM Students s
JOIN Grades g ON s.student_id = g.student_id
WHERE g.marks_obtained > (SELECT AVG(marks_obtained) FROM Grades);


SELECT c.course_name, f.name
FROM Courses c
JOIN Faculty f ON c.faculty_id = f.faculty_id
WHERE f.faculty_id IN (
SELECT faculty_id
FROM Faculty
WHERE DATEDIFF(CURDATE(), hire_date) / 365 >= 5
    );

    
SELECT s.student_id, s.name
FROM Students s
WHERE s.student_id IN (
    SELECT student_id
    FROM Attendance
    WHERE status != 'Present'
    GROUP BY student_id
    HAVING COUNT(attendance_id) > 10
);


## Q - 9 

SELECT MONTH(attendance_date) AS attendance_month, COUNT(attendance_id) AS total_records
FROM Attendance
GROUP BY attendance_month
ORDER BY attendance_month;

SELECT name, admission_date,
TIMESTAMPDIFF(YEAR, admission_date, CURDATE()) AS years_since_admission
FROM Students;

SELECT attendance_id, student_id, DATE_FORMAT(attendance_date, '%d-%m-%Y') AS formatted_date
FROM Attendance;

## Q - 10 

SELECT faculty_id, UPPER(name) AS uppercase_name
FROM Faculty;

SELECT student_id, TRIM(name) AS trimmed_name
FROM Students;

SELECT faculty_id, COALESCE(email, 'Email Not Provided') AS faculty_email
FROM Faculty;

## Q - 11 

SELECT s.student_id, s.name,
SUM(g.marks_obtained) AS total_marks,
RANK() OVER (ORDER BY SUM(g.marks_obtained) DESC) AS overall_rank
FROM Students s
JOIN Grades g ON s.student_id = g.student_id
GROUP BY s.student_id, s.name
ORDER BY overall_rank;

SELECT student_id, course_id, attendance_date, status,
COUNT(attendance_id) OVER (PARTITION BY student_id, course_id ORDER BY attendance_date) AS cumulative_days,
SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) OVER (PARTITION BY student_id, course_id ORDER BY attendance_date) AS cumulative_present,
(SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) OVER (PARTITION BY student_id, course_id ORDER BY attendance_date) * 100.0 / COUNT(attendance_id) OVER (PARTITION BY student_id, course_id ORDER BY attendance_date)) AS cumulative_attendance_pct
FROM Attendance;


SELECT
DATE_FORMAT(enrollment_date, '%Y-%m') AS enrollment_month,
COUNT(enrollment_id) AS students_in_month,
SUM(COUNT(enrollment_id)) OVER (ORDER BY DATE_FORMAT(enrollment_date, '%Y-%m')) AS running_total_enrolled
FROM Enrollments
GROUP BY enrollment_month
ORDER BY enrollment_month;

## Q - 12 

SELECT s.student_id, s.name, g.marks_obtained,
    CASE
        WHEN g.marks_obtained > 90 THEN 'Excellent'
        WHEN g.marks_obtained BETWEEN 75 AND 90 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_level
FROM Students s
JOIN Grades g ON s.student_id = g.student_id;


SELECT s.student_id, s.name,
(SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)) AS overall_attendance_pct,
CASE
WHEN (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)) > 80 THEN 'Regular'
WHEN (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.attendance_id)) BETWEEN 50 AND 80 THEN 'Irregular'
ELSE 'Defaulter'
END AS attendance_category
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name;
