<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Medicine List</title>
  <style>
    body { font-family: Arial; background: #f4f4f4; padding: 30px; }
    h2 { color: #2C3E50; text-align: center; }

    .message { text-align: center; padding: 10px; margin-bottom: 20px; }
    .success { background: #d4edda; color: #155724; }
    .error { background: #f8d7da; color: #721c24; }

    .search-form { text-align: center; margin-bottom: 20px; }
    input[type="text"] { padding: 10px; width: 300px; }
    button { padding: 10px; background: #2C3E50; color: white; border: none; border-radius: 5px; }

    table {
      width: 100%;
      border-collapse: collapse;
      background-color: white;
    }

    th, td {
      padding: 10px;
      border: 1px solid #ddd;
      text-align: center;
    }

    th {
      background-color: #2C3E50;
      color: white;
    }

    .update-btn {
      background-color: #3498db;
      padding: 5px 10px;
      color: white;
      text-decoration: none;
      border-radius: 5px;
    }

    .delete-btn {
      background-color: #e74c3c;
      color: white;
      border: none;
      padding: 5px 10px;
      border-radius: 5px;
      cursor: pointer;
    }

    form.inline { display: inline; }

    a.back-link {
      display: block;
      margin-top: 20px;
      font-weight: bold;
      color: #2C3E50;
      text-decoration: none;
      text-align: center;
    }

    a.back-link:hover {
      color: #1A5276;
    }
  </style>
</head>
<body>

<%
  String medicine_id = request.getParameter("medicine_id");
  String name = request.getParameter("name");
  String category = request.getParameter("category");
  String description = request.getParameter("description");
  String side_effects = request.getParameter("side_effects");
  String manufacture = request.getParameter("manufacture");
  String expire = request.getParameter("expire");
  String search = request.getParameter("search");
  String action = request.getParameter("action");

  try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "a123");

    if ("delete".equals(action)) {
      int idToDelete = Integer.parseInt(request.getParameter("id"));
      PreparedStatement ps = con.prepareStatement("DELETE FROM medicine WHERE medicine_id = ?");
      ps.setInt(1, idToDelete);
      int deleted = ps.executeUpdate();
      if (deleted > 0) {
%>
  <div class="message success">Medicine with ID <%= idToDelete %> deleted successfully.</div>
<%
      } else {
%>
  <div class="message error">Medicine not found.</div>
<%
      }
      ps.close();
    } else if (medicine_id != null && name != null && category != null && description != null && side_effects != null && manufacture != null && expire != null && action == null) {
      String insert = "INSERT INTO medicine (medicine_id, name, category, description, side_effects, manufacture, expire) VALUES (?, ?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'))";
      PreparedStatement ps = con.prepareStatement(insert);
      ps.setInt(1, Integer.parseInt(medicine_id));
      ps.setString(2, name);
      ps.setString(3, category);
      ps.setString(4, description);
      ps.setString(5, side_effects);
      ps.setString(6, manufacture);
      ps.setString(7, expire);
      ps.executeUpdate();
      ps.close();
%>
  <div class="message success">Medicine added successfully!</div>
<%
    }
%>

<h2>All Medicines</h2>

<div class="search-form">
  <form method="get">
    <input type="text" name="search" placeholder="Search by Name or Category" value="<%= (search != null ? search : "") %>" />
    <button type="submit">Search</button>
  </form>
</div>

<table>
  <tr>
    <th>ID</th>
    <th>Name</th>
    <th>Category</th>
    <th>Description</th>
    <th>Side Effects</th>
    <th>Manufacture</th>
    <th>Expire</th>
    <th>Actions</th>
  </tr>
<%
    String query = "SELECT * FROM medicine";
    if (search != null && !search.trim().isEmpty()) {
      query += " WHERE LOWER(name || category) LIKE ?";
    }
    query += " ORDER BY medicine_id";

    PreparedStatement stmt = con.prepareStatement(query);
    if (search != null && !search.trim().isEmpty()) {
      stmt.setString(1, "%" + search.toLowerCase() + "%");
    }

    ResultSet rs = stmt.executeQuery();

    while (rs.next()) {
      int id = rs.getInt("medicine_id");
      String mname = rs.getString("name");
      String mcat = rs.getString("category");
      String mdesc = rs.getString("description");
      String mside = rs.getString("side_effects");
      String mmanu = rs.getDate("manufacture").toString();
      String mexp = rs.getDate("expire").toString();
%>
  <tr>
    <td><%= id %></td>
    <td><%= mname %></td>
    <td><%= mcat %></td>
    <td><%= mdesc %></td>
    <td><%= mside %></td>
    <td><%= mmanu %></td>
    <td><%= mexp %></td>
    <td>
      <a class="update-btn" href="edit_medicine.jsp?medicine_id=<%= id %>&name=<%= mname %>&category=<%= mcat %>&description=<%= mdesc %>&side_effects=<%= mside %>&manufacture=<%= mmanu %>&expire=<%= mexp %>">Update</a>
      <form method="post" class="inline">
        <input type="hidden" name="id" value="<%= id %>" />
        <input type="hidden" name="action" value="delete" />
        <button type="submit" class="delete-btn">Delete</button>
      </form>
    </td>
  </tr>
<%
    }

    rs.close();
    stmt.close();
    con.close();
  } catch (Exception e) {
%>
  <div class="message error">Error: <%= e.getMessage() %></div>
<%
  }
%>
</table>

<a class="back-link" href="medicine.html">➕ Add Another Medicine</a>

</body>
</html>
