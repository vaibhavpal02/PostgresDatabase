-- Authors Table
CREATE TABLE Authors (
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_year INT,
    country VARCHAR(100)
);

-- Insert values into the Authors table
INSERT INTO Authors (name, birth_year, country)
VALUES
('George Orwell', 1903, 'UK'),
('J.K. Rowling', 1965, 'UK'),
('Isaac Asimov', 1920, 'Russia'),
('Mark Twain', 1835, 'USA'),
('Harper Lee', 1926, 'USA');

-- Books Table
CREATE TABLE Books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author_id INT REFERENCES Authors(author_id),
    category VARCHAR(50),
    published_year INT,
    copies_available INT
);

-- Insert values into the Books table
INSERT INTO Books (title, author_id, category, published_year, copies_available)
VALUES
('1984', 1, 'Dystopian', 1949, 5),
('Animal Farm', 1, 'Political Satire', 1945, 3),
('Harry Potter and the Philosopher''s Stone', 2, 'Fantasy', 1997, 7),
('Harry Potter and the Chamber of Secrets', 2, 'Fantasy', 1998, 6),
('Foundation', 3, 'Science Fiction', 1951, 4),
('The Adventures of Tom Sawyer', 4, 'Adventure', 1876, 8),
('To Kill a Mockingbird', 5, 'Fiction', 1960, 10);



-- Members Table
CREATE TABLE Members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    membership_date DATE
);

-- Insert values into the Members table
INSERT INTO Members (name, email, membership_date)
VALUES
('Alice Johnson', 'alice.johnson@example.com', '2023-01-15'),
('Bob Smith', 'bob.smith@example.com', '2023-02-10'),
('Charlie Brown', 'charlie.brown@example.com', '2023-03-05'),
('Diana Prince', 'diana.prince@example.com', '2023-04-20'),
('Edward Stark', 'edward.stark@example.com', '2023-05-25');


-- Borrowing Table
CREATE TABLE Borrowings (
    borrowing_id SERIAL PRIMARY KEY,
    book_id INT REFERENCES Books(book_id),
    member_id INT REFERENCES Members(member_id),
    borrowed_date DATE,
    return_date DATE
);

-----------------------------------------------------------------------------

--BASICS QUESTIONS:


-- Insert values into the Borrowings table
INSERT INTO Borrowings (book_id, member_id, borrowed_date, return_date)
VALUES
(1, 1, '2023-07-10', '2023-07-20'),
(3, 2, '2023-06-15', '2023-06-25'),
(5, 3, '2023-08-05', NULL),
(7, 4, '2023-09-01', '2023-09-15'),
(2, 5, '2023-09-10', NULL);


-- Q1. Select all books from the database. 
SELECT *FROM BOOKS;

-- Q2. Find the title and category of all books published in 2020.
SELECT TITLE,CATEGORY FROM BOOKS WHERE PUBLISHED_YEAR=2020;

-- Q3. List all authors from the USA.
SELECT NAME FROM AUTHORS WHERE COUNTRY ='USA';


-- Q4. Insert a new book into the Books table.
SELECT* FROM BOOKS;
INSERT INTO Books (book_id, title, author_id, category, published_year, copies_available)
VALUES (101, 'The Pragmatic Programmer', 1, 'Programming', 1999, 5);


-- Q5. Find all members who joined in the year 2023.
SELECT * FROM MEMBERS;
SELECT * FROM MEMBERS WHERE EXTRACT(YEAR FROM MEMBERSHIP_DATE)=2023;






-----------------------------------------------------------------------------
-- INTERMEDIATE QUESTIONS:



-- Q1 TOTAL NUMBER OF BOOKS BORROWED BY EACH MEMBER.
SELECT MEMBER_ID,COUNT(BOOK_ID) AS TOTAL_BORROWED FROM BORROWINGS GROUP BY MEMBER_ID;

--Q2 DISPLAY TITLE AND AUTHOR OF MOST BORROWED BOOK.
SELECT B.TITLE, A.NAME FROM BOOKS B
JOIN BORROWINGS BO 
ON BO.BOOK_ID=B.BOOK_ID
JOIN AUTHORS A
ON A.AUTHOR_ID=B.AUTHOR_ID
GROUP BY B.TITLE, A.NAME
ORDER BY COUNT(BO.BOOK_ID) DESC LIMIT 1;

--Q3 SHOW THE AUTHORS WHO HAS THE MOST BOOKS IN THE LIBRARY.

SELECT A.NAME,COUNT(B.TITLE) FROM AUTHORS A
JOIN BOOKS B
ON B.AUTHOR_ID=A.AUTHOR_ID
GROUP BY A.NAME
ORDER BY COUNT(B.TITLE) DESC LIMIT 1;

--Q4 FIND ALL MEMBERS WHO BORROWED MORE THAN 3 BOOKS.
SELECT MEMBER_ID, COUNT(BOOK_ID) AS TOTAL_BORROWED
FROM BORROWINGS
GROUP BY MEMBER_ID
HAVING COUNT(BOOK_ID)>3;

--Q5 Find all books that were borrowed but have not been returned for over 30 days.
SELECT B.TITLE FROM BOOKS B
JOIN BORROWINGS BO
ON B.BOOK_ID=BO.BOOK_ID
WHERE BO.RETURN_DATE IS NULL AND (CURRENT_DATE-BORROWED_DATE)>30;

--Q6 Find the youngest author in the library.
SELECT * FROM AUTHORS;
SELECT NAME FROM AUTHORS 
ORDER BY BIRTH_YEAR DESC
LIMIT 1;

--O7 Create a view that shows all books along with the author's name.
CREATE VIEW BOOKALONGAUTHORS AS
SELECT A.NAME, B.TITLE FROM AUTHORS A
JOIN BOOKS B ON A.AUTHOR_ID=B.AUTHOR_ID;

SELECT * FROM BOOKALONGAUTHORS;

--Q8 Find the top 3 categories with the most books.
SELECT CATEGORY, COUNT(*) FROM BOOKS
GROUP BY CATEGORY
ORDER BY COUNT(*) DESC
LIMIT 3;


--Q9 Display the names of all members who borrowed books written by 'J.K. Rowling'.
SELECT M.NAME 
FROM MEMBERS M
JOIN BORROWINGS BO ON M.MEMBER_ID = BO.MEMBER_ID
JOIN BOOKS B ON BO.BOOK_ID = B.BOOK_ID
JOIN AUTHORS A ON B.AUTHOR_ID = A.AUTHOR_ID
WHERE A.NAME = 'J.K. Rowling';




--------------------------------------------------------------------------------
--ADVANCED QUESTIONS


--Q1 WRITE A QUERY TO FIND MEMBER WHO NEVER BORROWED A BOOK.
SELECT NAME FROM MEMBERS
WHERE MEMBER_ID NOT IN(SELECT MEMBER_ID FROM BORROWINGS);


--Q2 AVG NUMBER OF DAYS BOOKS WERE BORROWED BEFORE BEING RETURNED IN 2022.
SELECT AVG(RETURN_DATE-BORROWED_DATE) AS AVG_DAYS FROM BORROWINGS
WHERE EXTRACT(YEAR FROM BORROWED_DATE)=2022;

-- 03 TOTAL NUMBER OF BOOKS BORROWED PER MONTH IN 2023
SELECT 
    EXTRACT(MONTH FROM BORROWED_DATE) AS MONTH,
    COUNT(*) AS TOTAL_BOOKS_BORROWED
FROM BORROWINGS
WHERE EXTRACT(YEAR FROM BORROWED_DATE) = 2023
GROUP BY MONTH
ORDER BY MONTH;


-- Q4 LIST ALL MEMBERS WHO BORROWED MORE THAN 2 BOOKS IN JANUARY 2023 BUT HAVENT BORROWED ANY SINCE.
SELECT MEMBER_ID,COUNT(BOOK_ID) FROM BORROWINGS
WHERE
EXTRACT(MONTH FROM BORROWED_DATE)=1 AND
EXTRACT(YEAR FROM BORROWED_DATE)=2023
GROUP BY MEMBER_ID
HAVING COUNT(BOOK_ID)>2
AND MEMBER_ID
 NOT IN
 (SELECT MEMBER_ID FROM BORROWINGS
WHERE
EXTRACT(MONTH FROM BORROWED_DATE)>1 AND
EXTRACT(YEAR FROM BORROWED_DATE)=2023);


-- Q5 Write a query to find the total number of authors who have at least one book borrowed in 2023.

SELECT COUNT(DISTINCT A.AUTHOR_ID)FROM AUTHORS A
JOIN BOOKS B ON A.AUTHOR_ID=B.AUTHOR_ID
JOIN BORROWINGS BO ON B.BOOK_ID=BO.BOOK_ID
WHERE EXTRACT (YEAR FROM BORROWED_DATE)=2023;


--Q6 Find the author with the fewest books in the library.
SELECT Authors.name, COUNT(Books.book_id) AS book_count 
FROM Authors 
INNER JOIN Books ON Authors.author_id = Books.author_id 
GROUP BY Authors.name 
ORDER BY book_count ASC 
LIMIT 1;

-- Q7 Create a trigger that updates the copies_available field in the Books table whenever a book is borrowed or returned.
CREATE OR REPLACE FUNCTION UPDATE_COPIES_AVAILABLE() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE BOOKS SET COPIES_AVAILABLE = COPIES_AVAILABLE - 1 WHERE BOOK_ID = NEW.BOOK_ID;
    ELSIF (TG_OP = 'UPDATE') AND NEW.RETURN_DATE IS NOT NULL THEN
        UPDATE BOOKS SET COPIES_AVAILABLE = COPIES_AVAILABLE + 1 WHERE BOOK_ID = NEW.BOOK_ID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER UPDATE_COPIES_AVAILABLE_TRIGGER
AFTER INSERT OR UPDATE ON BORROWINGS
FOR EACH ROW EXECUTE FUNCTION UPDATE_COPIES_AVAILABLE();






