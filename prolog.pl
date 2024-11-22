% Load required libraries
:- use_module(library(csv)).
:- use_module(library(thread)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_parameters)).

% Dynamic predicates for storing student data
:- dynamic student/4.

% HTTP handlers
:- http_handler(root(.), home_page, []).
:- http_handler(root(check), check_page, []).
:- http_handler('/api/scholarship/:id', scholarship_handler, []).
:- http_handler('/api/exam-permission/:id', exam_permission_handler, []).
:- http_handler('/api/debar-status/:id', debar_status_handler, []).

% CSS styles
css_style -->
    html(style(
'/* Global Styles */
body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    margin: 0;
    padding: 0;
    background-color: #f5f5f5;
}

.container {
    max-width: 800px;
    margin: 2rem auto;
    padding: 2rem;
    background-color: white;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.title {
    color: #2c3e50;
    text-align: center;
    margin-bottom: 2rem;
    font-size: 2.5rem;
}

/* Form Styles */
.form-container {
    max-width: 500px;
    margin: 0 auto;
}

.search-form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.input-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.input-group label {
    font-weight: bold;
    color: #34495e;
}

.input-field {
    padding: 0.8rem;
    border: 2px solid #ddd;
    border-radius: 5px;
    font-size: 1rem;
    transition: border-color 0.3s ease;
}

.input-field:focus {
    border-color: #3498db;
    outline: none;
}

.button-container {
    text-align: center;
    margin-top: 1rem;
}

.submit-button {
    background-color: #3498db;
    color: white;
    padding: 0.8rem 2rem;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 1rem;
    transition: background-color 0.3s ease;
}

.submit-button:hover {
    background-color: #2980b9;
}

/* Table Styles */
.result-container {
    margin-top: 2rem;
}

.student-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 2rem;
}

.student-table th,
.student-table td {
    padding: 1rem;
    border: 1px solid #ddd;
}

.student-table th {
    background-color: #f8f9fa;
    font-weight: bold;
    text-align: left;
    color: #2c3e50;
}

.data-cell {
    color: #34495e;
}

.status-positive {
    color: #27ae60;
    font-weight: bold;
}

.status-negative {
    color: #e74c3c;
    font-weight: bold;
}

/* Error Styles */
.error-message {
    color: #e74c3c;
    text-align: center;
    font-size: 1.2rem;
    margin: 2rem 0;
}

/* Back Button Styles */
.back-link {
    text-align: center;
}

.back-button {
    display: inline-block;
    background-color: #95a5a6;
    color: white;
    padding: 0.8rem 2rem;
    text-decoration: none;
    border-radius: 5px;
    transition: background-color 0.3s ease;
}

.back-button:hover {
    background-color: #7f8c8d;
}

@media (max-width: 600px) {
    .container {
        margin: 1rem;
        padding: 1rem;
    }
    
    .title {
        font-size: 2rem;
    }
    
    .student-table th,
    .student-table td {
        padding: 0.8rem;
    }
}')).

% Home page handler
home_page(_Request) :-
    reply_html_page(
        [title('Student Eligibility System'),
         \css_style],
        [div(class('container'),
            [h1(class('title'), 'Student Eligibility System'),
             div(class('form-container'),
                 form([action='/check', method='get', class('search-form')],
                      [div(class('input-group'),
                           [label([for=id], 'Enter Student ID:'),
                            input([name=id, type=text, class('input-field')])
                           ]),
                       div(class('button-container'),
                           input([type=submit, value='Check Status', class('submit-button')])
                          )
                      ])
                )])
        ]).

% Check page handler
check_page(Request) :-
    http_parameters(Request,
                   [ id(ID, [])
                   ]),
    (student(ID, Name, Attendance, CGPA) ->
        % Student found
        (eligible_for_scholarship(ID) ->
            ScholarshipStatus = 'Eligible',
            ScholarshipClass = 'status-positive'
        ;
            ScholarshipStatus = 'Not Eligible',
            ScholarshipClass = 'status-negative'
        ),
        (permitted_for_exam(ID) ->
            ExamStatus = 'Permitted',
            ExamClass = 'status-positive'
        ;
            ExamStatus = 'Not Permitted',
            ExamClass = 'status-negative'
        ),
        reply_html_page(
            [title('Student Status'),
             \css_style],
            [div(class('container'),
                [h1(class('title'), 'Student Status'),
                 div(class('result-container'),
                     table(class('student-table'),
                         [tr([th('Student ID'), td(class('data-cell'), ID)]),
                          tr([th('Name'), td(class('data-cell'), Name)]),
                          tr([th('Attendance'), td(class('data-cell'), Attendance)]),
                          tr([th('CGPA'), td(class('data-cell'), CGPA)]),
                          tr([th('Scholarship Status'), 
                              td(class(['data-cell', ScholarshipClass]), ScholarshipStatus)]),
                          tr([th('Exam Status'), 
                              td(class(['data-cell', ExamClass]), ExamStatus)])
                         ])),
                 div(class('back-link'),
                     a([href='/', class('back-button')], 'Back to Home'))
                ])
            ])
    ;
        % Student not found
        reply_html_page(
            [title('Error'),
             \css_style],
            [div(class('container'),
                [h1(class('title'), 'Error'),
                 div(class('error-message'),
                     p('Student not found')),
                 div(class('back-link'),
                     a([href='/', class('back-button')], 'Back to Home'))
                ])
            ])
    ).

% Eligibility rules
eligible_for_scholarship(StudentID) :-
    student(StudentID, _, Attendance, CGPA),
    Attendance >= 75,
    CGPA >= 9.0.

permitted_for_exam(StudentID) :-
    student(StudentID, _, Attendance, _),
    Attendance >= 75.

% API handlers
scholarship_handler(Request) :-
    http_parameters(Request, [id(ID, [])]),
    (eligible_for_scholarship(ID) ->
        Status = 'Eligible'
    ;
        Status = 'Not Eligible'
    ),
    reply_json_dict(_{status: Status}).

exam_permission_handler(Request) :-
    http_parameters(Request, [id(ID, [])]),
    (permitted_for_exam(ID) ->
        Status = 'Permitted'
    ;
        Status = 'Not Permitted'
    ),
    reply_json_dict(_{status: Status}).

debar_status_handler(Request) :-
    http_parameters(Request, [id(ID, [])]),
    (permitted_for_exam(ID) ->
        Status = 'Not Debarred'
    ;
        Status = 'Debarred'
    ),
    reply_json_dict(_{status: Status}).

% Safe CSV loading with error handling
load_student_data(File) :-
    (exists_file(File) ->
        (
            csv_read_file(File, [_Header|Rows], []),
            retractall(student(_, _, _, _)),  % Clear existing data
            maplist(assert_student_from_row, Rows),
            format('Successfully loaded student data from ~w~n', [File])
        )
        ;
        format('Error: CSV file not found. Please ensure students.csv exists.~n')
    ).

% Modified assert_student_from_row to handle the data directly
assert_student_from_row(Row) :-
    Row =.. [row|[ID, Name, Attendance, CGPA]],
    assert(student(ID, Name, Attendance, CGPA)),
    format('Added student: ~w~n', [ID]).

% Safe server stop predicate
stop_server :-
    (catch(
        http_stop_server(8000, []),
        Error,
        (format('Server was not running: ~w~n', [Error]), true)
    )).

% Server initialization
:- load_student_data('students.csv').
:- http_server(http_dispatch, [port(8000)]).