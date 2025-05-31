<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="dbconn.jsp" %>
<%@ include file="globalVar.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String sProductUuid = request.getParameter("productUuid");

    if (sProductUuid == null || sProductUuid.trim().isEmpty()) {
        out.println("<p style='color:red;'>상품 UUID가 없습니다. 삭제할 수 없습니다.</p>");
        return;
    }

    PreparedStatement pstmt = null;

    try {
        if (conn == null || conn.isClosed()) {
            out.println("<p style='color:red;'>데이터베이스 연결이 없습니다.</p>");
            return;
        }

        StringBuffer sql = new StringBuffer();
        sql.append("/* productDelMag - DELETE */ \n");
        sql.append("DELETE FROM PRODUCT \n");
        sql.append("WHERE PRODUCT_UUID = ? \n");

        System.out.println(sql.toString()); // 로그용

        pstmt = conn.prepareStatement(sql.toString());
        pstmt.setString(1, sProductUuid);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            out.println("<script>alert('상품이 삭제되었습니다.'); location.href='productMag.jsp';</script>");
        } else {
            out.println("<p style='color:red;'>삭제할 상품이 없습니다.</p>");
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>오류가 발생했습니다: " + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
