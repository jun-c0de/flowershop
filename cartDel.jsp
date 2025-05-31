<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body onload="document.redirectForm.submit();">
<%
String sProcessType = request.getParameter("processType");
String sCartUuid = request.getParameter("cartUuid");
String sCategoryCd = request.getParameter("categoryCd"); // 이전 카테고리 값

PreparedStatement pstmt = null;

try {
    StringBuffer sql = new StringBuffer();
    if ("P".equals(sProcessType)) {
        // 특정 카트 항목 하나 삭제
        sql.append("DELETE FROM CART WHERE CART_UUID = ?");
        pstmt = conn.prepareStatement(sql.toString());
        pstmt.setString(1, sCartUuid);
    } else if ("A".equals(sProcessType)) {
        // 전체 삭제 (조건 없이 모든 카트 삭제)
        sql.append("DELETE FROM CART");
        pstmt = conn.prepareStatement(sql.toString());
    } else {
        out.println("잘못된 요청입니다.");
    }

    if (pstmt != null) {
        pstmt.executeUpdate();
    }

} catch (SQLException ex) {
	out.println("취소시 오류가 발생했습니다.<br>");
	ex.printStackTrace();
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
<form id="redirectForm" name="redirectForm" action="product.jsp" method="post">
    <input type="hidden" id="categoryCd" name="categoryCd" value="<%=sCategoryCd%>">
</form>
</body>
</html>
