<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Doctor Directory</title>
    <style>
        :root {
            --primary: #3498db;
            --secondary: #2c3e50;
            --success: #2ecc71;
            --danger: #e74c3c;
            --light: #ecf0f1;
            --dark: #34495e;
            --gray: #95a5a6;
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
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background-color: var(--secondary);
            color: white;
            padding: 20px 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 1.8rem;
            font-weight: 700;
        }
        
        .logo span {
            color: var(--primary);
        }
        
        nav ul {
            display: flex;
            list-style: none;
        }
        
        nav ul li {
            margin-left: 20px;
        }
        
        nav ul li a {
            color: white;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            padding: 8px 12px;
            border-radius: 5px;
        }
        
        nav ul li a:hover {
            background-color: rgba(255,255,255,0.1);
        }
        
        .search-container {
            background-color: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            margin: 50px 0;
        }
        
        .search-container h2 {
            text-align: center;
            margin-bottom: 30px;
            color: var(--secondary);
        }
        
        .search-form {
            display: flex;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .search-input {
            flex: 1;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 5px 0 0 5px;
            font-size: 1rem;
        }
        
        .search-btn {
            padding: 15px 30px;
            background-color: var(--primary);
            color: white;
            border: none;
            border-radius: 0 5px 5px 0;
            cursor: pointer;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        
        .search-btn:hover {
            background-color: #2980b9;
        }
        
        .doctors-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 30px;
            margin: 50px 0;
        }
        
        .doctor-card {
            background-color: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
        }
        
        .doctor-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.1);
        }
        
        .doctor-header {
            background-color: var(--primary);
            color: white;
            padding: 20px;
            text-align: center;
        }
        
        .doctor-header h3 {
            margin: 0;
            font-size: 1.5rem;
        }
        
        .doctor-header p {
            margin: 5px 0 0;
            opacity: 0.9;
        }
        
        .doctor-body {
            padding: 20px;
        }
        
        .doctor-info {
            margin-bottom: 15px;
        }
        
        .info-label {
            font-weight: 600;
            color: var(--dark);
            display: block;
            margin-bottom: 5px;
        }
        
        .info-value {
            color: var(--secondary);
        }
        
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: var(--primary);
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            font-size: 1rem;
        }
        
        .btn-block {
            display: block;
            width: 100%;
            text-align: center;
        }
        
        .btn:hover {
            background-color: #2980b9;
        }
        
        .no-results {
            text-align: center;
            padding: 50px;
            color: var(--gray);
            font-size: 1.2rem;
            grid-column: 1 / -1;
        }
        
        footer {
            background-color: var(--secondary);
            color: white;
            text-align: center;
            padding: 30px 0;
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <header>
        <div class="container header-content">
            <div class="logo">Health<span>Care</span></div>
            <nav>
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <li><a href="patient_search.jsp">Patients</a></li>
                    <li><a href="doctor_search.jsp">Doctors</a></li>
                    <li><a href="appointment.html">Appointments</a></li>
                    <li><a href="medical_history.jsp">Medical History</a></li>
                </ul>
            </nav>
        </div>
    </header>
    
    <main class="container">
        <section class="search-container">
            <h2>Find a Doctor</h2>
            <form method="get" class="search-form">
                <input type="text" name="search" class="search-input" 
                       placeholder="Search by name, specialization, or contact" 
                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                <button type="submit" class="search-btn">Search</button>
            </form>
        </section>
        
        <section class="doctors-list">
            <%
                String searchQuery = request.getParameter("search");
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");
                    
                    String sql = "SELECT * FROM doctor";
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        sql += " WHERE LOWER(name) LIKE ? OR LOWER(specialization) LIKE ? OR LOWER(contactno) LIKE ?";
                    }
                    sql += " ORDER BY name";
                    
                    PreparedStatement stmt = con.prepareStatement(sql);
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        String searchParam = "%" + searchQuery.toLowerCase() + "%";
                        stmt.setString(1, searchParam);
                        stmt.setString(2, searchParam);
                        stmt.setString(3, searchParam);
                    }
                    
                    ResultSet rs = stmt.executeQuery();
                    
                    boolean hasResults = false;
                    while (rs.next()) {
                        hasResults = true;
                        int id = rs.getInt("doctor_id");
                        String name = rs.getString("name");
                        String specialization = rs.getString("specialization");
                        String contactno = rs.getString("contactno");
                        String clinic = rs.getString("clinic");
            %>
                        <div class="doctor-card">
                            <div class="doctor-header">
                                <h3>Dr. <%= name %></h3>
                                <p><%= specialization %></p>
                            </div>
                            <div class="doctor-body">
                                <div class="doctor-info">
                                    <span class="info-label">Clinic</span>
                                    <span class="info-value"><%= clinic %></span>
                                </div>
                                <div class="doctor-info">
                                    <span class="info-label">Contact</span>
                                    <span class="info-value"><%= contactno %></span>
                                </div>
                                <a href="patient_appointment.jsp?doctor_id=<%= id %>" class="btn btn-block">Book Appointment</a>
                            </div>
                        </div>
            <%
                    }
                    
                    if (!hasResults) {
            %>
                        <div class="no-results">
                            <p>No doctors found matching your search criteria.</p>
                            <p>Please try a different search term.</p>
                        </div>
            <%
                    }
                    
                    rs.close();
                    stmt.close();
                    con.close();
                } catch (Exception e) {
            %>
                    <div class="no-results">
                        <p>Error loading doctor information: <%= e.getMessage() %></p>
                    </div>
            <%
                    e.printStackTrace();
                }
            %>
        </section>
    </main>
    
    <footer>
        <div class="container">
            <p>&copy; 2025 Healthcare Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>