local dialogs = {}

dialogs["initial_info"] = {
	title = "",
	content = {
		"%01% Bom dia espíritos, viram meu mestre?",
		"%02% Ben, Temos uma notícia não muito boa",
		"%01% O que aconteceu?",
		"%02% Seu mestre desapareceu esta manhã, tememos que ele tenha ido além do vale",
		"%01% Mas isso... Como pode? Ele sempre disse que deixar o vale é proibido",
		"%02% Ele parecia estar sendo dominado por poderes além dele, o guarda não pôde detê-lo",
		"%02% Ben, a partida do sacerdote antes da hora é algo muito sério e pode comprometer, não só o vale, mas todo o reino de Odihna!",
		"%02% Você precisa encontrá-lo",
		"%01% Mas eu não sei como sair do vale, o guarda nunca me deixará passar",
		"%02% O artefato que você acabou de pegar pode te ajudar a ganhar mais poder com o tempo.",
		"%02% Mas por hora, vai lhe dar o conhecimento que precisa para entrar em contato com os sábios antigos. Em meditação você encontrará as repostas que precisa",
		"%02% Sempre que encontrar o totem dos sábios você poderá meditar e então solucionar seus problemas, a solução nem sempre será clara, mas o tempo o fará entender...",
		"%01% Mas eu... Não consigo sozinho, vocês não podem me ajudar?",
		"%02% Já lhe demos toda a ajuda que poderiamos lhe dar, agora apenas vá, não perca tempo!"
	},
	img_one_path = "images/BheadA.png",
	img_two_path = "images/tree.png",
}

dialogs["see_guard_body"] = {
	title = "",
	content = {
		"%01% O que??? O guarda está morto... Não era assim que eu gostaria que fosse...",
		"%01% ...Sinto muito."
	},
	img_one_path = "images/BheadA.png"
}

dialogs["guard_good_morning"] = {
	title = "",
	content = {
		"%02% Bom dia Ben... Você sabe o que aconteceu? Eu estou meio tonto..."
	},
	img_one_path = "images/BheadA.png",
	img_two_path = "images/BheadB.png"
}

dialogs["ren_initial"] = {
	title = "",
	content = {
		"%01% As trevas de Gólgota me sufocam, eu nem sei mais há quanto tempo estou aqui...",
        "%01% Preciso sair a qualquer custo..."
	},
	img_one_path = "images/RheadA.png"
}

return dialogs