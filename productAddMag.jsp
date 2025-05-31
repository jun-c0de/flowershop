<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ include file="menuMag.jsp" %>
<%@ include file="dbconn.jsp" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>상품 추가</title>
<script>
function save() {
    var frm = document.getElementById("frmProductSave");
    if(frmChk()) {
        frm.action = "productSaveMag.jsp";
        frm.submit();
    }
}

function frmChk() {
    var frm = document.getElementById("frmProductSave");
    if(frm.categoryCd.value == "") {
        alert("카테고리를 선택해주세요.");
        frm.categoryCd.focus();
        return false;
    }
    if(frm.productName.value.trim() == "") {
        alert("상품명을 입력해주세요.");
        frm.productName.focus();
        return false;
    }
    if(frm.productPrice.value.trim() == "") {
        alert("가격을 입력해주세요.");
        frm.productPrice.focus();
        return false;
    }
    if(isNaN(frm.productPrice.value.trim())) {
        alert("가격은 숫자만 입력 가능합니다.");
        frm.productPrice.focus();
        return false;
    }
    if(frm.productQuantity.value.trim() == "") {
        alert("수량을 입력해주세요.");
        frm.productQuantity.focus();
        return false;
    }
    if(isNaN(frm.productQuantity.value.trim())) {
        alert("수량은 숫자만 입력 가능합니다.");
        frm.productQuantity.focus();
        return false;
    }
    return true;
}
</script>
</head>
<body>

    <h2 style="text-align: center;">상품 추가</h2>

    <form id="frmProductSave" name="frmProductSave" method="post" onsubmit="return false;">
        <input type="hidden" id="actionMethod" name="actionMethod" value="I">

        <table border="1" style="width: 60%; margin: 0 auto; border-collapse: collapse;">
            <tr>
                <th style="width: 30%;">카테고리</th>
                <td>
                    <select id="categoryCd" name="categoryCd">
                        <option value="">선택</option>
                        <option value="01">장미</option>
                        <option value="02">백합</option>
                        <option value="03">튤립</option>
                        <option value="04">해바라기</option>
                    </select>
                </td>
            </tr>
            <tr>
                <th>상품명</th>
                <td><input type="text" id="productName" name="productName" style="width: 100%;"></td>
            </tr>
            <tr>
                <th>가격</th>
                <td><input type="text" id="productPrice" name="productPrice" style="width: 100%;"></td>
            </tr>
            <tr>
                <th>수량</th>
                <td><input type="text" id="productQuantity" name="productQuantity" style="width: 100%;"></td>
            </tr>
            <tr>
                <th>설명</th>
                <td><textarea id="productDesc" name="productDesc" rows="4" style="width: 100%;"></textarea></td>
            </tr>
            <tr>
                <th>정렬순서</th>
                <td><input type="text" id="productSort" name="productSort" style="width: 100%;"></td>
            </tr>
            <tr>
                <td colspan="2" style="text-align: center; padding: 10px;">
                    <input type="submit" value="저장" onclick="save();" style="padding: 5px 20px;">
                    <input type="reset" value="취소" style="padding: 5px 20px;">
                </td>
            </tr>
        </table>
    </form>

</body>
</html>
