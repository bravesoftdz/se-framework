local module_rank = {};

function module_rank:showme()
	--ע��lua��Ϣ
	fol.listen:register(self, fol.msgcode.Rank_OnClose,  fol.rank.doClose);
	--ע�����¼�
	fol.uipkg:registerClickEvent("frmRank", "btnClose",  fol.msgcode.Rank_OnClose);
	--��ʾ
	fol.uipkg:showWindow("frmRank");
end

function module_rank:doClose()
	--�ر�
	fol.uipkg:closeWindow("frmRank");
end

return module_rank;