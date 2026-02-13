
# Get all student grades for their courses and qualifications

select student.first_name, student.last_name, course.name, course.qualification, grades.grade
from student 
  inner join grades on student.id = grades.student_id
  inner join course on grades.course_id = course.id;