<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    String role = null;

    if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
        out.println("<p style='color:red;'>Username or password cannot be empty.</p>");
    } else {
        // Trim after null check to avoid NPE
        username = username.trim();
        password = password.trim();
        
        try {
            // Load Oracle JDBC driver
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Connect to Oracle DB
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            
            try {
                con = DriverManager.getConnection(
                    "jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

                // Prepare SQL to check credentials and retrieve role
                // Using parameterized query to prevent SQL injection
                String sql = "SELECT role FROM users WHERE username = ? AND password = ?";
                ps = con.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, password);

                rs = ps.executeQuery();

                if (rs.next()) {
                    role = rs.getString("role");
                    
                    // Store user info in session
                    session.setAttribute("username", username);
                    session.setAttribute("role", role);

                    // Redirect based on role (case-insensitive comparison)
                    if ("admin".equalsIgnoreCase(role)) {
                        response.sendRedirect("index.html");
                        return;
                    } else if ("doctor".equalsIgnoreCase(role)) {
                        response.sendRedirect("doctorDashboard.jsp");
                        return;
                    } else if ("patient".equalsIgnoreCase(role)) {
                        response.sendRedirect("patient_home.html");
                        return;
                    } else {
                        out.println("<p style='color:red;'>Unknown role: " + role + "</p>");
                    }
                } else {
                    out.println("<p style='color:red;'>Invalid username or password.</p>");
                    // Debugging: Show the actual query being executed
                    out.println("<p>Debug: Executed query: " + sql.replace("?", "'" + username + "'").replace("?", "'" + password + "'") + "</p>");
                }
            } finally {
                // Close DB resources in finally block
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (con != null) try { con.close(); } catch (SQLException e) {}
            }
        } catch (ClassNotFoundException e) {
            out.println("<p style='color:red;'>JDBC driver not found.</p>");
        } catch (SQLException e) {
            out.println("<p style='color:red;'>Database error: " + e.getMessage() + "</p>");
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        }
    }
%>