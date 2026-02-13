select student.first_name, student.last_name, course.name, course.qualification, student_has_course.grade, tutor.title, tutor.name
from (( student inner join student_has_course 
        on student.id = student_has_course.student_id)
           inner join course 
           on student_has_course.course_id = course.id
              inner join tutor 
              on course.id = tutor.course_id
      );