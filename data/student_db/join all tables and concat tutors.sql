
# Select student, course, grade and all tutors for a specific student
SELECT 
    student.first_name, 
    student.last_name, 
    course.name, 
    grades.grade,
    GROUP_CONCAT(CONCAT(tutor.title, ' ', tutor.name)SEPARATOR ', ') AS tutors   # Group all the rows into 1 but concat the tutor names as they will be different
FROM student
INNER JOIN grades ON student.id = grades.student_id
INNER JOIN course ON course.id = grades.course_id
INNER JOIN tutor ON course.id = tutor.course_id
WHERE student.last_name = 'Jet' AND course.name = 'Electronics'
GROUP BY   # Collapse all rows into a single column on the following fields which will all be the same
    student.first_name, 
    student.last_name, 
    course.name, 
    grades.grade;


