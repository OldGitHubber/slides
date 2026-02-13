select first_name, last_name, course.name, grades.grade, tutor.title, tutor.name 
from student
  inner join grades on student.id = student_id
  inner join course on course.id = grades.course_id
  inner join tutor on course.id = tutor.course_id
where student.last_name = "Jet" and course.name = "Electronics";



