local module_rank = {};

function module_rank:showme()
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Rank_OnClose,  fol.rank.doClose);
	--ע�����¼�
	fol.uipackage:registerClickEvent("frmRank", "btnClose",  fol.msgcode.Rank_OnClose);
	
	fol.uipackage:showWindow("frmRank");
end

function module_rank:doClose()
	--�ر�
	fol.uipackage:closeWindow("frmRank");
end

return module_rank;