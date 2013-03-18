angular.module('fastClick', []).directive('fastClick', ()->
	(scope, elem, attr)->	
		$(elem).fastClick( (e)->			
			scope.$apply(attr.fastClick);
		)
)
		

angModule = angular.module('piModule', ['fastClick','ngCookies','ngSanitize']).
	config( ($routeProvider)->
		$routeProvider.
			when('/', {controller:FrontPageCtrl, templateUrl:'index.html'}).
			otherwise({redirectTo:'/'})
	)


FrontPageCtrl = ($rootScope, $scope, $cookieStore) ->
	self = @
	_piInputted  = ""	
	_pi = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989"
	_timerTest = null
	_timeStampTest = null
	_timerUltimate = null
	_timeStampUltimate = null
	_pageState = null
	window.root = $rootScope
	window.scope = $scope

	pairUp = (str)->
		ret = ""
		for i in [0..str.length] by 2
			ret += "#{str.substring(i,i+2)} "
		ret
	
	piBlocks = ()->
		itemlist = []
		for i in [0.._pi.length-1] by 10
			itemlist.push({
				pi: pairUp(_pi.substring(i,i+10))
				idx: i
			})
		itemlist
		
	renderPiInputted = (str)->
		blocks = []
		correct_count = 0
		for o in [0..str.length-1] by 10
			s = str.substring(o, Math.min(o+10, str.length))
			block = []
			for i in [0..s.length-1]
				digitStr = if (0<i&&i%2==1) then "#{s[i]} " else s[i]
				correct = (s[i] == _pi[o+i])
				block.push({
					digit: digitStr
					correct: correct
				})
				correct_count++ if correct
			blocks.push({
				block: block
				idx: o
			})
		$scope.digits = str.length
		$scope.correct = correct_count
		blocks
		
	timerTestHandle = (ev)->
		$scope.timerTest = Math.round((new Date().getTime() - _timeStampTest)/1000)
		$scope.$digest()
		@
	$scope.piInputted = []
	
	changeTemplate = (template)->		
		switch template 
			when "welcome"
				_pageState = "welcome"
				$scope.templateContent = "welcome.html"
			when "pi.html"
				_pageState = "pi"			
				$scope.templateContent = template
			when "practicePi.html"
				_pageState = "practice"			
				$scope.templateContent = template
			when "ultimate"
				_pageState = "ultimate"			
				if($scope.piUltimateState.limit? && $scope.piUltimateState.limit > 0)
					$scope.templateContent = "ultimatePi.html"
				else
					$scope.templateContent = "ultimatePiStart.html"
			else
				console.log("Warning: unknown template!")		
		console.log("Argument: #{template} -> #{$scope.templateContent}, #{_pageState} (scope: #{$scope.$id})")		
		self
	
	chooseUltimateDigit = ()->
		if( !$scope.piUltimateState.limit? || $scope.piUltimateState.limit > _pi.length)
			console.write("(#{$scope.piUltimateState.limit}?? Cannot index more than #{_pi.length} digits)")
			return

		index = Math.floor((Math.random()*$scope.piUltimateState.limit))
		console.log("Choosing #{index+1} from #{$scope.piUltimateState.limit} digits")		
		ending = "th"
		switch ( (index+1) % 10)
			when 1 then ending = 'st'
			when 2 then ending = 'nd'
			when 3 then ending = 'rd'

		$scope.piUltimateState.currentIndex = index
		$scope.piUltimateState.currentEnding = ending
		index
		
	numpadPressPractice = (key)->
		somethingChanged = false
		switch key
			when "del" 
				if( _piInputted.length > 0 )
					_piInputted = _piInputted.substring(0,_piInputted.length-1)
					somethingChanged = true;
			when "res" 
				somethingChanged = (_piInputted != "")
				_piInputted = ""
				if(_timerTest)
					clearInterval(_timerTest)
					_timerTest = null
					$scope.timerTest = 0
			else
				if(!_timerTest)
					_timerTest = setInterval(timerTestHandle,1000)
					_timeStampTest = new Date().getTime()
				_piInputted += key
				somethingChanged = true
				
		if( somethingChanged )
			$scope.piInputted = renderPiInputted(_piInputted)
		self
		
	renderUltimateBlock = (idx, correct)->
		res = []
		startIdx = idx - idx % 10
		endIdx = startIdx + 9
		
		for i in [startIdx..endIdx]
			digitStr = if (0<i&&i%2==1) then "#{_pi[i]} " else _pi[i]
			cssClass = "common"
			if( idx == i )
				if( correct ) 
					cssClass = "true"
				else
					cssClass = "false"
				
			res.push({
				digit: digitStr
				cssClass: cssClass
			})	
		res
		
	numpadPressUltimate = (key)->
		if( !$scope.piUltimateState.currentIndex? || $scope.piUltimateState.currentIndex > _pi.length )
			console.log("Current index is invalid")
			return
			
		somethingChanged = false
		correct = null
		switch key
			when "del" 
				correct	= null			
				chooseUltimateDigit()
				$scope.piUltimateState.lastAnswer.index = null				
				line = []
				somethingChanged = true				
			when "res" 
				$scope.piUltimateState.limit = null
				changeTemplate("ultimate")
				correct	= null
				$scope.piUltimateState.lastAnswer.index = null				
				line = []
				somethingChanged = true				
			else
				correct = (key == _pi[$scope.piUltimateState.currentIndex])
				line = renderUltimateBlock($scope.piUltimateState.currentIndex, correct)
				somethingChanged = true
				$scope.piUltimateState.lastAnswer.index = $scope.piUltimateState.currentIndex
				chooseUltimateDigit()

		if( somethingChanged )
			$scope.piUltimateState.lastAnswer.correct = correct
			$scope.piUltimateState.lastAnswer.line = line
			
		self
	
	$scope.menuClick = (template)->		
		changeTemplate(template)
		$('a.btn-navbar').click()			
		window.hideAddressBar()		
		self		
	
	$scope.numPadPress = (key)->
		switch _pageState
			when "practice" then numpadPressPractice(key)
			when "ultimate" then numpadPressUltimate(key)
			else 
				console.log("Using numpad in unknown state (#{_pageState})!")
		self
	
	$scope.digits = 0
	$scope.correct = 0
	$scope.timerTest = 0
	$scope.ultimateNumpadTemplate = null
	$scope.piOptions = [10,25,50,75,100,150,200,250,300,350,400,500,600,700,800,900,1000]
	$scope.piFormatted = piBlocks()
	
	$scope.piUltimateState = {}
	$scope.piUltimateState.limit = 0
	$scope.piUltimateState.currentIndex = null	
	$scope.piUltimateState.currentEnding = null
	$scope.piUltimateState.lastAnswer = {}	
	$scope.piUltimateState.lastAnswer.correct = null	
	$scope.piUltimateState.lastAnswer.line = []
	$scope.piUltimateState.lastAnswer.index = null	

	$scope.$watch("piInputted", (newVal, oldVal, scope)->
		if( newVal? )
			objDiv = document.getElementById("pi-input")
			if( objDiv? )
				objDiv.scrollTop = objDiv.scrollHeight	
	)
	
	$scope.$watch("piUltimateState.limit", (newVal, oldVal, scope)->
		if( newVal && newVal > 0)
			console.log("Playing among #{newVal} digits")			
			chooseUltimateDigit()
			console.log("Playing among #{newVal} digits")			
			$scope.templateContent = "ultimatePi.html"
		null
	, true)
	
	changeTemplate("welcome")
	
	self
	
window.hideAddressBar = ()->
	setTimeout(()->
		window.scrollTo(0, 1)
	,0)
	window
	
window.addEventListener("load",()->
	window.hideAddressBar()
)