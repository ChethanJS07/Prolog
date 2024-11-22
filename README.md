# Student Eligibility System

A web-based system built with SWI-Prolog to check student eligibility for scholarships and exams based on attendance and CGPA.

## Prerequisites

1. Install SWI-Prolog:
   - **Windows**: Download and install from [SWI-Prolog Downloads](https://www.swi-prolog.org/download/stable)
   - **Linux**: `sudo apt-get install swi-prolog`
   - **macOS**: `brew install swi-prolog`

2. Required SWI-Prolog Libraries (automatically loaded by the program):
   - csv
   - thread
   - http/thread_httpd
   - http/http_dispatch
   - http/http_json
   - http/http_cors
   - http/html_write
   - http/http_files
   - http/http_parameters

## File Structure

```
project_directory/
├── prolog.pl          # Main server code
├── students.csv       # Student data file
└── README.md         # This file
```

## Setting Up the Student Data

1. Create a file named `students.csv` in the same directory as `prolog.pl`
2. Format the CSV file with these headers:
   ```csv
   ID,Name,Attendance,CGPA
   ```
3. Add student records, one per line. Example:
   ```csv
   ID,Name,Attendance,CGPA
   1001,John Doe,85,9.2
   1002,Jane Smith,70,8.5
   1003,Bob Wilson,95,9.5
   ```

## Running the Server

1. Open terminal/command prompt
2. Navigate to the project directory:
   ```bash
   cd path/to/project_directory
   ```
3. Start SWI-Prolog:
   ```bash
   swipl prolog.pl
   ```
4. The server should automatically start on port 8000
5. If you need to manually start/stop the server:
   ```prolog
   % To stop server
   ?- stop_server.
   
   % To start server
   ?- http_server(http_dispatch, [port(8000)]).
   ```

## Accessing the System

1. Open a web browser
2. Go to `http://localhost:8000`
3. Enter a student ID to check their eligibility status

## Eligibility Criteria

1. **Scholarship Eligibility**:
   - Attendance >= 75%
   - CGPA >= 9.0

2. **Exam Permission**:
   - Attendance >= 75%

## API Endpoints

The system provides the following REST API endpoints:

- `GET /api/scholarship/:id` - Check scholarship eligibility
- `GET /api/exam-permission/:id` - Check exam permission
- `GET /api/debar-status/:id` - Check debarment status

Example API usage:
```bash
curl http://localhost:8000/api/scholarship/1001
```

## Troubleshooting

1. **Server Won't Start**
   - Check if port 8000 is already in use
   - Try stopping and restarting the server
   - Ensure you have necessary permissions

2. **"File not found" Error**
   - Verify that `students.csv` exists in the same directory as `prolog.pl`
   - Check file permissions

3. **"Student not found" Error**
   - Verify the student ID exists in `students.csv`
   - Check CSV file format and data

4. **Loading Issues**
   - Ensure all required libraries are installed
   - Try restarting SWI-Prolog

## System Features

1. Web-based interface for checking student eligibility
2. Automatic calculation of scholarship and exam eligibility
3. Color-coded status indicators
4. Responsive design for mobile devices
5. RESTful API endpoints for integration
6. CSV-based data storage

## License

This project is open source and available under the MIT License.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Verify your SWI-Prolog installation
3. Check file permissions and paths
4. Contact system administrator

---

**Note**: Replace any placeholder values (like paths or specific instructions) with actual values relevant to your implementation.
