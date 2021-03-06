local module_rank = {};

function module_rank:showme()
	--注册lua消息
	fol.listen:register(self, fol.msgcode.Rank_OnClose,  fol.rank.doClose);
	--注册点击事件
	fol.uipkg:registerClickEvent("frmRank", "btnClose",  fol.msgcode.Rank_OnClose);
	--显示
	fol.uipkg:showWindow("frmRank");
end

function module_rank:doClose()
	--关闭
	fol.uipkg:closeWindow("frmRank");
end

return module_rank;