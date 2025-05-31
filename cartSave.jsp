<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>장바구니 처리</title>
</head>
<body onload="document.redirectForm.submit();">
<%
    String sCategoryCd = request.getParameter("categoryCd");
    String sProductUuid = request.getParameter("productUuid");

    PreparedStatement pstmt = null;

    try {
        // 장바구니에 상품 추가 (수량은 기본 1개)
        String sql = "INSERT INTO cart (cart_uuid, product_uuid, quantity, reg_dt) " +
                     "VALUES (SYS_GUID(), ?, ?, SYSDATE)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, sProductUuid);
        pstmt.setInt(2, 1); // 수량 기본값: 1
        pstmt.executeUpdate();

    } catch (SQLException ex) {
        out.println("SQLException: " + ex.getMessage());
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<!-- 상품 목록 페이지로 다시 이동 -->
<form id="redirectForm" name="redirectForm" action="product.jsp" method="post">
    <input type="hidden" id="categoryCd" name="categoryCd" value="<%=sCategoryCd%>">
</form>
</body>
</html>
