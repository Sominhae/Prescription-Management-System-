<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Patient Details</title>
  <style>
    :root {
      --primary-color: #3498db;
      --secondary-color: #2c3e50;
      --success-color: #2ecc71;
      --danger-color: #e74c3c;
      --light-color: #ecf0f1;
      --dark-color: #34495e;
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
      max-width: 1000px;
      margin: 30px auto;
      padding: 20px;
    }
    
    .card {
      background: white;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
      overflow: hidden;
      margin-bottom: 30px;
    }
    
    .card-header {
      background-color: var(--secondary-color);
      color: white;
      padding: 20px;
      font-size: 1.5rem;
      font-weight: 600;
    }
    
    .card-body {
      padding: 30px;
    }
    
    .patient-info {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 20px;
    }
    
    .info-group {
      margin-bottom: 15px;
    }
    
    .info-label {
      font-weight: 600;
      color: var(--dark-color);
      margin-bottom: 5px;
      display: block;
    }
    
    .info-value {
      padding: 10px;
      background-color: var(--light-color);
      border-radius: 5px;
    }
    
    .action-buttons {
      display: flex;
      gap: 10px;
      margin-top: 30px;
      flex-wrap: wrap;
    }
    
    .btn {
      padding: 10px 20px;
      border-radius: 5px;
      text-decoration: none;
      font-weight: 500;
      transition: all 0.3s ease;
      border: none;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      justify-content: center;
    }
    
    .btn-primary {
      background-color: var(--primary-color);
      color: white;
    }
    
    .btn-danger {
      background-color: var(--danger-color);
      color: white;
    }
    
    .btn-secondary {
      background-color: var(--secondary-color);
      color: white;
    }
    
    .btn-home {
      background-color: #7f8c8d;
      color: white;
    }
    
    .btn:hover {
      opacity: 0.9;
      transform: translateY(-2px);
    }
    
    .search-container {
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
      margin-bottom: 30px;
    }
    
    .search-form {
      display: flex;
      gap: 10px;
      max-width: 600px;
      margin: 0 auto;
    }
    
    .search-input {
      flex: 1;
      padding: 12px 15px;
      border: 1px solid #ddd;
      border-radius: 5px;
      font-size: 16px;
    }
    
    .search-btn {
      padding: 12px 25px;
      background-color: var(--primary-color);
      color: white;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      font-size: 16px;
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
    
    .not-found {
      text-align: center;
      padding: 40px;
      color: var(--dark-color);
    }
    
    .icon {
      margin-right: 8px;
    }
    
    .navigation-buttons {
      display: flex;
      justify-content: center;
      margin-top: 20px;
      gap: 10px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="search-container">
      <h2 style="text-align: center; margin-bottom: 20px; color: var(--secondary-color);">Patient Search</h2>
      <form method="get" class="search-form">
        <input type="text" name="patient_id" class="search-input" placeholder="Enter Patient ID" required>
        <button type="submit" class="search-btn">Search</button>
      </form>
    </div>

    <%
      String patientId = request.getParameter("patient_id");
      
      if (patientId != null && !patientId.trim().isEmpty()) {
        try {
          Class.forName("oracle.jdbc.driver.OracleDriver");
          Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");
          
          String query = "SELECT * FROM patient WHERE patient_id = ?";
          PreparedStatement stmt = con.prepareStatement(query);
          stmt.setInt(1, Integer.parseInt(patientId));
          
          ResultSet rs = stmt.executeQuery();
          
          if (rs.next()) {
            int id = rs.getInt("patient_id");
            String name = rs.getString("name");
            Date dob = rs.getDate("dob");
            String gender = rs.getString("gender");
            String address = rs.getString("address");
            String contactno = rs.getString("contactno");
            
            // Format the date
            SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy");
            String formattedDob = sdf.format(dob);
    %>
            <div class="card">
              <div class="card-header">
                Patient Details
              </div>
              <div class="card-body">
                <div class="patient-info">
                  <div class="info-group">
                    <span class="info-label">Patient ID</span>
                    <div class="info-value"><%= id %></div>
                  </div>
                  
                  <div class="info-group">
                    <span class="info-label">Full Name</span>
                    <div class="info-value"><%= name %></div>
                  </div>
                  
                  <div class="info-group">
                    <span class="info-label">Date of Birth</span>
                    <div class="info-value"><%= formattedDob %></div>
                  </div>
                  
                  <div class="info-group">
                    <span class="info-label">Gender</span>
                    <div class="info-value"><%= gender %></div>
                  </div>
                  
                  <div class="info-group">
                    <span class="info-label">Contact Number</span>
                    <div class="info-value"><%= contactno %></div>
                  </div>
                  
                  <div class="info-group" style="grid-column: span 2;">
                    <span class="info-label">Address</span>
                    <div class="info-value"><%= address %></div>
                  </div>
                </div>
                
                <div class="action-buttons">
                  <a href="edit_patient.jsp?patient_id=<%= id %>&name=<%= name %>&dob=<%= dob %>&gender=<%= gender %>&address=<%= address %>&contactno=<%= contactno %>" 
                     class="btn btn-primary">
                    <span class="icon">✏️</span> Edit Patient
                  </a>
                  <form method="post" style="display: inline;">
                    <input type="hidden" name="id" value="<%= id %>"/>
                    <input type="hidden" name="action" value="delete"/>
                    <button type="submit" class="btn btn-danger">
                      <span class="icon">🗑️</span> Delete Patient
                    </button>
                  </form>
                  <a href="medical_history.jsp?patient_id=<%= id %>" class="btn btn-secondary">
                    <span class="icon">📋</span> View Medical History
                  </a>
                </div>
              </div>
            </div>
    <%
          } else {
    %>
            <div class="not-found">
              <h3>Patient not found</h3>
              <p>No patient record exists with ID: <%= patientId %></p>
            </div>
    <%
          }
          
          rs.close();
          stmt.close();
          con.close();
          
        } catch (Exception e) {
    %>
          <div class="message error">
            Error: <%= e.getMessage() %>
          </div>
    <%
          e.printStackTrace();
        }
      } else if (patientId != null && patientId.trim().isEmpty()) {
    %>
        <div class="message error">
          Please enter a valid Patient ID
        </div>
    <%
      }
    %>
    
    <!-- Added Home Button -->
    <div class="navigation-buttons">
      <a href="patient_home.html" class="btn btn-home">
        <span class="icon">🏠</span> Back to Home
      </a>
    </div>
  </div>
</body>
</html>