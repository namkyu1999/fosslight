<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="/WEB-INF/constants.jsp"%>
<script type="text/javascript">
//<![CDATA[
	/*global $ */
	/*jslint browser: true, nomen: true */
	$(document).ready(function () {
		'use strict';
		
		noticeList.load();
	});	
	
	// 함수
	var fn = {
		// Grid rowid의 max값
		getMaxIdNo: function(grid){
			var ids = [];
			ids = $("#list").jqGrid('getDataIDs');
			
			return (ids.length == 0) ? 0 : Math.max.apply(Math, ids);
		},
		// Grid row 추가
		addRow: function(grid){
			var newIdNo = fn.getMaxIdNo(grid) + 1;
			$("#list").jqGrid("addRowData", newIdNo, {cdNo: newIdNo}, "first");	
		},
		// Grid row 삭제
		delRow: function(gid,delRowId){
			// 삭제할 rowid 저장
			// 기존 row인 경우만 deleteRowList에 추가
			if(delRowId <= noticeList.lastIdNo) {
				noticeList.deleteRowList.push($("#list").jqGrid("getRowData",delRowId));
			}
			
			// 삭제할 rowid가 추가/수정 목록에 있을 경우 삭제
			var idx = noticeList.modifyRowId.indexOf(delRowId);
			
			if(idx != -1) {
				noticeList.modifyRowId.splice(idx, 1);
			}
			
			$("#list").jqGrid('delRowData',delRowId);
		},
		
		// 수정된 마지막 row 저장
		saveLastRow: function(grid){
			$("#list").jqGrid("editCell", 0, 0, false);		// $("#list").jqGrid("editCell", row, col, false); 반드시 edit focus를 해제시킨다. 해제 시키지 않을 경우 값이 <input ....>으로 저장된다.
			$("#list").jqGrid("saveRow", noticeList.lastEditRowId);
			$("#list").jqGrid("setRowData", noticeList.lastEditRowId, false, { background : "#feffc4" });	// 수정된 row 색 변경

			// 수정된 rowid 저장
			if(noticeList.modifyRowId.length == 0) {
				noticeList.modifyRowId.push(noticeList.lastEditRowId);
			} else {
				noticeList.modifyRowId.forEach(function(){		// 중복제외
					if(noticeList.modifyRowId.indexOf(noticeList.lastEditRowId) == -1) {
						noticeList.modifyRowId.push(noticeList.lastEditRowId);
					}
				});
			}
		}
	};
	
	// Grid formatter
	var gridFormatter = {
		// row 삭제버튼 동적 추가
		delBtn: function(cellvalue, options, rowObject){
			var button = "<input type=\"button\" value=\"delete\" class=\"btnCLight darkgray\" onclick=\"fn.delRow("+"'"+options.gid+"'"+",'"+options.rowId+"')\" />";

			return button;
		}
	};
	
	var updateDialogAdd = {
            url:"notice/saveAjax"
                , closeAfterAdd: true
                , reloadAfterSubmit: true
                , modal: true
			    , serializeDelData: function(postdata) {
			        return JSON.stringify(postdata);
			    }
			    , beforeShowForm: function(formid) {
			        $("#tr_seq", formid).css("display", "none");
			        var appendHtml = '<div id="noticeEdit" style="width:500px; height:150px;"></div>';
        			$("#tr_notice", formid).show();
    				$("#notice", formid).hide();
			        $("#tr_notice", formid).children().eq(1).append(appendHtml);
			        var _editor = CKEDITOR.instances.noticeEdit;
			        
					if(_editor) {
						_editor.destroy();
					}
					
					CKEDITOR.replace('noticeEdit', {});
			    }
			    , onClose: function() {
			    	$("#noticeEdit").remove();
			    }
                , afterSubmit: function(response, postdata) {
                    if("false" == response.responseJSON.isValid) {
                        alertify.error('<spring:message code="msg.common.valid" />', 0);
                        createValidMsg('FrmGrid_list', response.responseJSON);

                        return [false, '<spring:message code="msg.common.valid" />', ""]
                    } else {
                        alertify.success('<spring:message code="msg.common.success" />');

                        return [true,"",""]
                    }
                }
                , beforeSubmit: function(postdata, formid) {
                	postdata.notice = CKEDITOR.instances.noticeEdit.getData();
                	$("span.retxt", formid).remove();

                	return [true];
                }
                ,width: "600"
	};
	
	var updateDialogEdit = {
            url:"notice/saveAjax"
                , closeAfterEdit: true
                , reloadAfterSubmit: true
                , modal: true
			    , serializeDelData: function(postdata) {
			        return JSON.stringify(postdata);
			    }
			    , beforeShowForm: function(formid) {
			        var appendHtml = '<div id="noticeEdit" style="width:500px; height:150px;">'+$("#notice", formid).val()+'</div>';
        			$("#tr_notice", formid).show();
    				$("#notice", formid).hide();
			        $("#tr_notice", formid).children().eq(1).append(appendHtml);
			        var _editor = CKEDITOR.instances.noticeEdit;

					if(_editor) {
						_editor.destroy();
					}
					
					CKEDITOR.replace('noticeEdit', {});
			    }
			    , onClose: function() {
			    	$("#noticeEdit").remove();
			    }
                , afterSubmit: function(response, postdata) {
                    if("false" == response.responseJSON.isValid) {
                        alertify.error('<spring:message code="msg.common.valid" />', 0);
                        createValidMsg('FrmGrid_list', response.responseJSON);

                        return [false, '<spring:message code="msg.common.valid" />', ""]
                    } else {
                        alertify.success('<spring:message code="msg.common.success" />');

                        return [true,"",""]
                    }
                }
                , beforeSubmit: function(postdata, formid) {
                	postdata.notice = CKEDITOR.instances.noticeEdit.getData();
                    $("span.retxt", formid).remove();

                    return [true];
                }
                ,width: "600"
                ,viewPagerButtons: false
	};
	
	var updateDialogDel = {
            url:"notice/saveAjax"
                , closeAfterDel: true
                , reloadAfterSubmit: true
                , modal: true
                , onclickSubmit: function(params, rowid) {
                    var rowData = $("#list").jqGrid("getRowData", rowid);

                    return rowData;
                }
			    , afterSubmit: function(response, postdata) {
                    if("false" == response.responseJSON.isValid) {
                        alertify.error('<spring:message code="msg.common.valid" />', 0);

                        return [false, '<spring:message code="msg.common.valid" />', ""]
                    } else {
                        alertify.success('<spring:message code="msg.common.success" />');

                        return [true,"",""]
                    }
			    }
	};
	
	var noticeList = {
		modifyRowId: [],		// 수정된 모든 rowid
		deleteRowList: [],		// 삭제할 LIST
		lastEditRowId: "",		// 마지막 수정된 rowid 저장 변수
		lastIdNo: "",			// 서버에서 가져온 마지막 id
		
		load: function(){
			noticeList.modifyRowId = [];
			noticeList.deleteRowList = [];
			noticeList.lastEditRowId = "";
			
			$("#list").jqGrid({
				url: '/system/notice/listAjax'
				, datatype: 'json'
				, jsonReader: {
					repeatitems: false,
					id:'gridId',
					root:function(obj){return obj.rows;},
					page:function(obj){return obj.page;},
					total:function(obj){return obj.total;},
					records:function(obj){return obj.records;}
				}
				, colNames: ['gridId', 'Notice No', 'Title', 'Notice', 'notice', 'Start Date', 'End Date', 'Publish']
				, colModel: [
                    {name: 'gridId', index: 'gridId', key:true, editable:false, hidden:true},
                    {name: 'seq', index: 'seq', width: 50, align: 'center', editable:true},
					{name: 'title', index: 'title', width: 200, align: 'left', editable:true, editrules : {required: true}},
					{name: 'replaceNotice', index: 'replaceNotice', width: 400, align: 'left', editable:false},
                    {name: 'notice', index: 'notice', editable:true, hidden:true},
					{name: 'sDate', index: 'sDate', width: 50, align: 'center', editable:true, editrules : {required: true}, 
						editoptions:{
							size:20, 
							dataInit:function(el){ 
								$(el).datepicker({dateFormat:'yy-mm-dd'}); 
							}, 
							defaultValue: function(){ 
								var currentTime = new Date(); 
								var month = parseInt(currentTime.getMonth() + 1); 
								month = month <= 9 ? "0"+month : month; 
								var day = currentTime.getDate(); 
								day = day <= 9 ? "0"+day : day; 
								var year = currentTime.getFullYear(); 
								return year+"-"+month + "-"+day;
							}
						}
					},
					{name: 'eDate', index: 'eDate', width: 50, align: 'center', editable:true, editrules : {required: true}, 
						editoptions:{
							size:20, 
							dataInit:function(el){ 
								$(el).datepicker({dateFormat:'yy-mm-dd'}); 
							}, 
							defaultValue: function(){ 
								var currentTime = new Date(); 
								var month = parseInt(currentTime.getMonth() + 1); 
								month = month <= 9 ? "0"+month : month; 
								var day = currentTime.getDate(); 
								day = day <= 9 ? "0"+day : day; 
								var year = currentTime.getFullYear(); 
								return year+"-"+month + "-"+day;
							}
						}
					},
					{name: 'publishYn', index: 'publishYn', width: 50, align: 'center', editable:true, edittype:"checkbox", editoptions: {value: "Y:N:N"}}
				]
				, emptyrecords: "Nothing to display"
				, autoencode: true
				, editurl: 'clientArray'
				, rowNum: ${ct:getConstDef("DISP_PAGENATION_DEFAULT")}
				, rowList: [${ct:getConstDef("DISP_PAGENATION_LIST_STR")}]
  				, autowidth: true
				, pager: '#pager'
				, gridview: true
				, sortable: function (permutation) {}
				, sortname: 'seq'
				, sortorder: 'desc'
				, viewrecords: true
				, height: 'auto'
				, loadonce: false
				// 데이터 로딩 후
				, loadComplete: function(data) {}
			});
			
            $("#list").jqGrid('navGrid', "#pager", {edit:true, add:true, del:true, search:false, refresh:false}, updateDialogEdit, updateDialogAdd, updateDialogDel);
		}		
	};
</script>