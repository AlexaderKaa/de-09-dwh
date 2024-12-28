/*SELECT AVG(B.salary) as avg_salary,
             B.department as department
FROM personal_data AS A 
    INNER JOIN hr_data AS B ON A.employee_id = B.employee_id
        WHERE A.age < 35 AND B.work_experience < 5
            GROUP BY B.department; 
            

Попробуйте переписать SQL-запрос в запрос в форме CTE.
Старый запрос:

SELECT AVG(B.salary) as avg_salary,
             B.department as department
FROM personal_data AS A 
    INNER JOIN hr_data AS B ON A.employee_id = B.employee_id
        WHERE A.age < 35 AND B.work_experience < 5
            GROUP BY B.department; 
Разделите этот запрос на три части:
Первая часть получает информацию только из таблицы hr_data с учётом опыта работы (work_experience).
Вторая часть получает информацию только из таблицы personal_data с учётом возраста (age).
Третья часть объединяет данные из двух предыдущих и выдаёт результат группировки по отделам (department) и агрегации среднего по зарплате (salary).
*/

WITH 
hr AS (
-- первая часть получает информацию только из таблицы hr_data с учётом опыта работы (work_experience)
SELECT employee_id, salary, department FROM hr_data WHERE work_experience < 5
), 
personal AS (
-- вторая часть получает информацию только из таблицы personal_data с учётом возраста (age)
SELECT employee_id, age FROM personal_data WHERE age < 35 
)
-- третья часть объединяет данные из двух предыдущих и выдаёт результат группировки по отделам (department) и агрегации среднего по зарплате (salary)
SELECT AVG(salary), department
FROM personal INNER JOIN hr ON hr.employee_id = personal.employee_id
GROUP BY department

;