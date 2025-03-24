select * from department ;
select * from employee ;
select * from job ;
select * from nation ;
select * from location ;
select * from sal_grade ;

-- 1. 부서코드가 노옹철 사원과 같은 소속의 직원 명단 조회하세요.
select emp_name
from employee
 where dept_code = (select
					DEPT_CODE
                    from employee where emp_name='노옹철');
-- 2. 전 직원의 평균 급여보다 많은 급여를 받고 있는 직원의 사번, 이름, 직급코드, 급여를 조회하세요.
select emp_id, emp_name, job_code, salary 
	   from employee
	  where salary > (select avg(salary) from employee);
-- 3. 노옹철 사원의 급여보다 많이 받는 직원의 사번, 이름, 부서코드, 직급코드, 급여를 조회하세요.
select emp_id, emp_name,dept_code, job_code, salary 
	   from employee
	  where salary > (select salary from employee where emp_name='노옹철');
-- 4. 가장 적은 급여를 받는 직원의 사번, 이름, 부서코드, 직급코드, 급여, 입사일을 조회하세요.
select emp_id, emp_name,dept_code, job_code, salary ,hire_date
	   from employee
	  where salary = (select min(salary) from employee);
-- *** 서브쿼리는 SELECT, FROM, WHERE, HAVING, ORDER BY절에도 사용할 수 있다.

-- 5. 부서별 최고 급여를 받는 직원의 이름, 직급코드, 부서코드, 급여 조회하세요.
-- 서브 쿼리
select max(salary)from employee group by dept_code;

select emp_name,dept_code, job_code, salary
	   from  employee 
       where (dept_code, salary) in  
       (select dept_code, max(salary)from employee group by dept_code);


-- *** 여기서부터 난이도 극상

-- 6. 관리자에 해당하는 직원에 대한 정보와 관리자가 아닌 직원의 정보를 추출하여 조회하세요.
-- 사번, 이름, 부서명, 직급, '관리자' AS 구분 / '직원' AS 구분
-- HINT!! is not null, union(혹은 then, else), distinct
select 
	  e.emp_id,
      e.emp_name,
      d.dept_title,
      j.job_name,
      '관리자' as 구분
      from employee e
   join department d on e.dept_code = d.DEPT_ID
   join job j on e.JOB_CODE=j.JOB_CODE
where e.manager_id is not null
union 
select 
	  e.emp_id,
      e.emp_name,
      d.dept_title,
      j.job_name,
      '직원' as 구분
      from employee e
   join department d on e.dept_code = d.DEPT_ID
   join job j on e.JOB_CODE=j.JOB_CODE
   where e.manager_id is null;
      


-- 7. 자기 직급의 평균 급여를 받고 있는 직원의 사번, 이름, 직급코드, 급여를 조회하세요.
-- 단, 급여와 급여 평균은 만원단위로 계산하세요.
-- HINT!! round(컬럼명, -5)
-- 서브 쿼리
select round(avg(salary),-5) from employee group by job_code;

select emp_Id,emp_name,job_code,salary 
	from employee 
	 where (job_code,SALARY) 
	  in (select job_code,round(avg(salary),-5) 
	  from employee 
	  group by job_code);

-- 8. 퇴사한 여직원과 같은 부서, 같은 직급에 해당하는 직원의 이름, 직급코드, 부서코드, 입사일을 조회하세요.
-- 서브 쿼리
select job_code ,dept_code from employee where ent_yn='y';

select emp_name,
	   job_code,
       dept_code,
       hire_date from employee where (job_code ,dept_code) =
       (select job_code ,dept_code 
       from employee 
       where ent_yn = 'y');

-- 다른 풀이법
SELECT E.EMP_NAME
	 , E.JOB_CODE
     , E.DEPT_CODE
     , E.HIRE_DATE
  FROM EMPLOYEE E
  JOIN (SELECT DEPT_CODE
			 , JOB_CODE
		  FROM EMPLOYEE
		 WHERE ENT_YN = 'Y'
           AND EMP_NO LIKE '%-2%'
		) E2
	ON E.DEPT_CODE = E2.DEPT_CODE
   AND E.JOB_CODE = E2.JOB_CODE
 WHERE E.ENT_YN = 'N'
   ;



-- 9. 급여 평균 3위 안에 드는 부서의 부서 코드와 부서명, 평균급여를 조회하세요.
-- HINT!! limit
select e.dept_code,
	   avg(e.salary) as avg_salary , 
       d.dept_title 
    from  employee e 
   join department d 
     on dept_code = dept_id 
group by e.DEPT_CODE, 
	     d.dept_title 
         order by 
         avg_salary desc limit 3;
         
 -- 다른 풀이법        
SELECT S.DEPT_CODE
	 , D.DEPT_TITLE
     , S.AVG_SAL AS '평균급여'
  FROM (SELECT DEPT_CODE
			 , AVG(SALARY) AS AVG_SAL
		  FROM EMPLOYEE
		 GROUP BY DEPT_CODE
		 ORDER BY AVG_SAL DESC
		 LIMIT 3
	 ) S
  JOIN DEPARTMENT D
    ON S.DEPT_CODE = D.DEPT_ID
 ;

-- 10. 부서별 급여 합계가 전체 급여의 총 합의 20%보다 많은 부서의 부서명과, 부서별 급여 합계를 조회하세요.
select d.dept_title,
       s.sum_sal
       from (select 
			 dept_code, 
		     sum(salary) as sum_sal
	          from employee 
                group by dept_code) s
			join department d 
               on s.dept_code = d.dept_id 
		where s.sum_sal > ( select sum(salary)*0.2 
							from employee );
                    
  -- 각 부서별 급여 합 쿼리
  select dept_code, 
		sum(salary) 
	from employee group by dept_code;                  
-- 전체 급여 합 쿼리
select sum(salary)*0.2 from employee ;