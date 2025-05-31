<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
Connection conn = null;
try {
	String url = "jdbc:oracle:thin:@211.210.75.86:1521:XE";
	String user = "BT0006";
	String password = "BT0006";
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection(url, user, password);
} catch(Exception e) {
    out.println("DB 연결 실패: " + e.getMessage());
    e.printStackTrace();
}
%>
