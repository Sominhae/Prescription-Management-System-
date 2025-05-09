<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book Appointment</title>
    <style>
        :root {
            --primary: #3498db;
            --secondary: #2c3e50;
            --success: #2ecc71;
            --danger: #e74c3c;
            --light: #ecf0f1;
            --dark: #34495e;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 800px;
            margin: 30px auto;
            padding: 20px;
        }
        
        .card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 30px;
        }
        
        .card-header {
            background-color: var(--primary);
            color: white;
            padding: 20px;
            font-size: 1.5rem;
            font-weight: 600;
        }
        
        .card-body {
            padding: 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--dark);
        }
        
        input[type="text"],
        input[type="date"],
        input[type="time"],
        select,
        textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 1rem;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 25px;
            background-color: var(--primary);
            color: white;
            text-decoration: none;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        
        .btn:hover {
            background-color: #2980b9;
        }
        
        .message {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            text-align: center;
        }
        
        .success {
            background-color: #d4edda;
            color: #155724;
        }
        
        .error {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .doctor-info {
            background-color: var(--light);
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .info-label {
            font-weight: 600;
            color: var(--dark);
        }
    </style>
</head>
<body>
    <div class="container">
        <%
            // Get doctor_id from URL parameter
            String doctorId = request.getParameter("doctor_id");
            String patientId = (String) session.getAttribute("patient_id");
            
            if (doctorId == null || doctorId.trim().isEmpty()) {
                response.sendRedirect("doctor_search.jsp");
                return;
            }
            
            // Database connection variables
            Connection con = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                // Load JDBC driver
                Class.forName("oracle.jdbc.driver.OracleDriver");
                
                // Connect to database
                con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");
                
                // Get doctor details
                String doctorSql = "SELECT * FROM doctor WHERE doctor_id = ?";
                pstmt = con.prepareStatement(doctorSql);
                pstmt.setInt(1, Integer.parseInt(doctorId));
                rs = pstmt.executeQuery();
                
                if (!rs.next()) {
                    out.println("<div class='message error'>Doctor not found</div>");
                    return;
                }
                
                String doctorName = rs.getString("name");
                String specialization = rs.getString("specialization");
                String clinic = rs.getString("clinic");
                
                // Close resources
                rs.close();
                pstmt.close();
                
                // Handle form submission
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    String appointmentDate = request.getParameter("appointment_date");
                    String appointmentTime = request.getParameter("appointment_time");
                    String purpose = request.getParameter("purpose");
                    
                    // Combine date and time
                    String appointmentDateTime = appointmentDate + " " + appointmentTime;
                    
                    // Insert appointment
                    String insertSql = "INSERT INTO appointment (doctor_id, patient_id, appointment, purpose, status) " +
                                      "VALUES (?, ?, TO_DATE(?, 'YYYY-MM-DD HH24:MI'), ?, 'Scheduled')";
                    
                    pstmt = con.prepareStatement(insertSql);
                    pstmt.setInt(1, Integer.parseInt(doctorId));
                    pstmt.setInt(2, Integer.parseInt(patientId));
                    pstmt.setString(3, appointmentDateTime);
                    pstmt.setString(4, purpose);
                    
                    int rowsAffected = pstmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        out.println("<div class='message success'>Appointment booked successfully!</div>");
                    } else {
                        out.println("<div class='message error'>Failed to book appointment</div>");
                    }
                }
        %>
        
        <div class="card">
            <div class="card-header">
                Book Appointment
            </div>
            <div class="card-body">
                <div class="doctor-info">
                    <h3>Dr. <%= doctorName %></h3>
                    <p><span class="info-label">Specialization:</span> <%= specialization %></p>
                    <p><span class="info-label">Clinic:</span> <%= clinic %></p>
                </div>
                
                <form method="post">
                    <input type="hidden" name="doctor_id" value="<%= doctorId %>">
                    
                    <div class="form-group">
                        <label for="appointment_date">Appointment Date</label>
                        <input type="date" id="appointment_date" name="appointment_date" required 
                               min="<%= new SimpleDateFormat("yyyy-MM-dd").format(new Date()) %>">
                    </div>
                    
                    <div class="form-group">
                        <label for="appointment_time">Appointment Time</label>
                        <input type="time" id="appointment_time" name="appointment_time" required min="09:00" max="17:00">
                    </div>
                    
                    <div class="form-group">
                        <label for="purpose">Purpose of Visit</label>
                        <select id="purpose" name="purpose" required>
                            <option value="">Select a purpose</option>
                            <option value="General Consultation">General Consultation</option>
                            <option value="Follow-up Visit">Follow-up Visit</option>
                            <option value="Prescription Refill">Prescription Refill</option>
                            <option value="Test Results">Test Results Discussion</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    
                    <div class="form-group" id="otherPurposeGroup" style="display:none;">
                        <label for="other_purpose">Please specify</label>
                        <input type="text" id="other_purpose" name="other_purpose">
                    </div>
                    
                    <div class="form-group">
                        <button type="submit" class="btn">Book Appointment</button>
                        <a href="doctor_search.jsp" class="btn" style="background-color: var(--secondary);">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
        
        <%
            } catch (Exception e) {
                out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
                e.printStackTrace();
            } finally {
                // Close resources
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (con != null) try { con.close(); } catch (SQLException e) {}
            }
        %>
    </div>

    <script>
        // Show/hide other purpose field based on selection
        document.getElementById('purpose').addEventListener('change', function() {
            var otherGroup = document.getElementById('otherPurposeGroup');
            otherGroup.style.display = (this.value === 'Other') ? 'block' : 'none';
        });
        
        // Set minimum time to current time if selecting today's date
        document.getElementById('appointment_date').addEventListener('change', function() {
            var today = new Date().toISOString().split('T')[0];
            var timeInput = document.getElementById('appointment_time');
            
            if (this.value === today) {
                var now = new Date();
                var hours = now.getHours().toString().padStart(2, '0');
                var minutes = now.getMinutes().toString().padStart(2, '0');
                timeInput.min = hours + ':' + minutes;
            } else {
                timeInput.min = '09:00';
            }
        });
    </script>
</body>
</html>