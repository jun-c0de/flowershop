<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="globalVar.jsp" %>
<%@ include file="dbconn.jsp" %>
<!DOCTYPE html>
<html>
<body onload="document.redirectForm.submit();">
<%
    ResultSet rs = null;
    PreparedStatement pstmt = null;

    try {
        String sOrderUuid = "";
        int iMasterResult = 0;
        int iItemResult = 0;
        int iCartDelResult = 0;

        // 고유 키값 생성
        String keySql = "SELECT SYS_GUID() AS UUID FROM DUAL";
        pstmt = conn.prepareStatement(keySql);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            sOrderUuid = rs.getString("UUID");
        }
        rs.close();
        pstmt.close();

        // 총합 가격 계산
        String totPriceSql = "SELECT SUM(B.PRODUCT_PRICE * A.QUANTITY) TOT_PRICE " +
                             "FROM cart A " +
                             "INNER JOIN product B ON A.PRODUCT_UUID = B.PRODUCT_UUID";
        pstmt = conn.prepareStatement(totPriceSql);
        rs = pstmt.executeQuery();
        int iTotalPrice = 0;
        if (rs.next()) {
            iTotalPrice = rs.getInt("TOT_PRICE");
        }
        rs.close();
        pstmt.close();
        

        if (iTotalPrice > 0) {
            // 마스터 테이블에 주문 저장
            String masterInsSql = "INSERT INTO ORDER_MASTER (SHOP_UUID, ORDER_UUID, ORDER_STATUS, TOT_PRICE, REG_DT) " +
                                  "VALUES (?, ?, 'PC', ?, SYSDATE)";
            pstmt = conn.prepareStatement(masterInsSql);
            pstmt.setString(1, sShopUuid);
            pstmt.setString(2, sOrderUuid);
            pstmt.setInt(3, iTotalPrice);
            iMasterResult = pstmt.executeUpdate();
            pstmt.close();
        } else {
            out.println("<script>alert('카트 정보가 없습니다.'); history.back();</script>");
        }

        if (iMasterResult > 0) {
            // 아이템 테이블에 상품 저장
            String itemInsSql = "INSERT INTO ORDER_ITEM (ORDER_ITEM_UUID, SHOP_UUID, ORDER_UUID, PRODUCT_UUID, QUANTITY, PRICE, REG_DT) " +
                                "SELECT SYS_GUID(), ?, ?, A.PRODUCT_UUID, A.QUANTITY, B.PRODUCT_PRICE, SYSDATE " +
                                "FROM cart A INNER JOIN product B ON A.PRODUCT_UUID = B.PRODUCT_UUID";
            pstmt = conn.prepareStatement(itemInsSql);
            pstmt.setString(1, sShopUuid);
            pstmt.setString(2, sOrderUuid);
            iItemResult = pstmt.executeUpdate();
            pstmt.close();

            // 상품 수량 차감
            String updateSql = "UPDATE PRODUCT A SET A.PRODUCT_QUANTITY = A.PRODUCT_QUANTITY - " +
                               "(SELECT SUM(B.QUANTITY) FROM CART B WHERE A.PRODUCT_UUID = B.PRODUCT_UUID) " +
                               "WHERE EXISTS (SELECT 1 FROM CART B WHERE A.PRODUCT_UUID = B.PRODUCT_UUID)";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.executeUpdate();
            pstmt.close();
        }

        if (iItemResult > 0) {
            // 카트 비우기
            String cartDelSql = "DELETE FROM cart";
            pstmt = conn.prepareStatement(cartDelSql);
            iCartDelResult = pstmt.executeUpdate();
            pstmt.close();
        }

        if (iItemResult > 0 && iCartDelResult > 0) {
            out.println("<script>alert('주문되었습니다.');</script>");
        }

    } catch (SQLException ex) {
        out.println("SQLException: " + ex.getMessage());
        ex.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<form id="redirectForm" name="redirectForm" action="product.jsp" method="post">
    <input type="hidden" name="categoryCd" value="01">
</form>
</body>
</html>
