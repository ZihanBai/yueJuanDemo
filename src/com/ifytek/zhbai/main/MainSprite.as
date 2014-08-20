package com.ifytek.zhbai.main 
{
	import com.ifytek.zhbai.command.CommandData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	//引入PNGEncoder
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Encoder;
	/**
	 * ...
	 * @author 柏梓涵
	 */
	public class MainSprite extends Sprite 
	{
		//全局字符串常量
		private static const DAGOU:String = "打钩";
		private static const DACHA:String = "打叉";
		//边框颜色
		private const LINECOLOR:uint = 0xff0000;
		//填充颜色
		private const BACKCOLOR:uint = 0xffffff;
		//container的宽
		private const WIDTH:int = 1000;
		//container的高
		private const HEIGHT:int = 300;
		//mainSprite下的子对象
		private var container:Sprite;
		//container下的子对象
		private var pictureContainer:Sprite;
		//pictureContainer下的子对象
		private var bitmap:Bitmap = null;
		private var canvas:Shape;
		
		//container下的子对象
		private var btnPanel:Sprite;
		//btnPanel下的子对象
		private var gouBtn:Sprite;
		private var chaBtn:Sprite;
		private var wanChengBtn:Sprite;
		private var cheXiaoBtn:Sprite;
		//批注样式，默认为0
		private var piZhuStyle:int = 0;
		//用于撤销的操作栈
		private var stackAction:Array;
		//用于解决单击、双击事件冲突的bool值
		private var double:Boolean;
		/**
		 * 构造函数
		 */
		public function MainSprite() 
		{
			super();
			//初始化各组件
			init();
			//画出Container边框
			drawContainer();
			//绘制按钮面板
			drawBtnPanel();
			//载入图片
			loadPicture();
		}
		/**
		 * 初始化各组件
		 */
		private function init():void {
			container = new Sprite();
			pictureContainer = new Sprite();
			btnPanel = new Sprite();
			gouBtn = new Sprite();
			chaBtn = new Sprite();
			wanChengBtn = new Sprite();
			cheXiaoBtn = new Sprite();
			canvas = new Shape();
			stackAction = new Array();
			double = false;
		}
		/**
		 * 画出Container边框
		 */
		private function drawContainer():void {
			container.graphics.lineStyle(0, BACKCOLOR);
			container.graphics.beginFill(BACKCOLOR);
			container.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			container.graphics.endFill();
			addChild(container);
		}
		/**
		 * 绘制按钮面板
		 */
		private function drawBtnPanel():void {
			btnPanel.graphics.lineStyle(2, LINECOLOR);
			btnPanel.graphics.beginFill(BACKCOLOR);
			btnPanel.graphics.drawRoundRect(0, 0, 105, 30, 10);
			btnPanel.graphics.endFill();
			btnPanel.x = 10;
			btnPanel.y = HEIGHT - 30;
			//绘制各按钮
			drawBtns();
		}
		/**
		 * 载入图片
		 */
		private function loadPicture():void {
			var loader:Loader = new Loader();
			//图片的URL
			loader.load(new URLRequest("http://www.baizihan.cn/wp-content/uploads/2014/04/wordpress3.9.png"));
			//载入成功
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
			/**
			 * 载入成功
			 * @param	evt
			 */
			function complete(evt:Event):void {
				var bmd:BitmapData = new BitmapData(loader.width, loader.height);
				bmd.draw(loader);
				bitmap = new Bitmap(bmd);
				bitmap.x = 10;
				bitmap.y = 10;
				pictureContainer.addChild(bitmap);
			}
			//双击图片显示按钮面板
			pictureContainer.doubleClickEnabled = true;
			pictureContainer.addEventListener(MouseEvent.DOUBLE_CLICK, doubleHandler);
			//将图片加入为Container的子对象
			container.addChild(pictureContainer);
			pictureContainer.addEventListener(MouseEvent.CLICK, clickHandler);
			function clickHandler(evt:MouseEvent):void {
				double = false;
				var timer:Timer = new Timer(260, 1);
				timer.start();
				timer.addEventListener(TimerEvent.TIMER, func);
			}
			function doubleHandler(evt:MouseEvent):void {
				double = true;
			}
			function func(evt:TimerEvent):void {
				if (double) {
					//双击出现面板
					displayBtn();
				}else {
					//单击批注
					piZhuAction();
				}
			}
		}
		/**
		 * 在鼠标指针附近显示按钮面板
		 */
		private function displayBtn():void {
				//让双击时不响应单机事件，可以回撤单击事件
				//cheXiaoAction(evt);
				//if (evt.currentTarget == pictureContainer) {
					btnPanel.x = mouseX;
					btnPanel.y = mouseY;
					container.addChild(btnPanel);
				//}
		}
		/**
		 * 绘制打钩按钮
		 */
		private function drawGou():void {
			gouBtn.graphics.lineStyle(2, LINECOLOR);
			gouBtn.graphics.beginFill(BACKCOLOR);
			gouBtn.graphics.drawRoundRect(0, 0, 20, 20, 10, 10);
			gouBtn.graphics.endFill();
			gouBtn.graphics.moveTo(4, 10);
			gouBtn.graphics.lineTo(7, 14);
			gouBtn.graphics.lineTo(16, 7);
			gouBtn.x = 5;
			gouBtn.y = 5;
			btnPanel.addChild(gouBtn);
			//单击按钮改变批注样式
			gouBtn.name = DAGOU;
			gouBtn.addEventListener(MouseEvent.CLICK, changePiZhuStyle);
		}
		/**
		 * 绘制打叉按钮
		 */
		private function drawCha():void {
			chaBtn.graphics.lineStyle(2, LINECOLOR);
			chaBtn.graphics.beginFill(BACKCOLOR);
			chaBtn.graphics.drawRoundRect(0, 0, 20, 20, 10, 10);
			chaBtn.graphics.endFill();
			chaBtn.graphics.moveTo(5, 5);
			chaBtn.graphics.lineTo(15, 15);
			chaBtn.graphics.moveTo(5, 15);
			chaBtn.graphics.lineTo(15, 5);
			chaBtn.x = 30;
			chaBtn.y = 5;
			btnPanel.addChild(chaBtn);
			//单击按钮改变批注样式
			chaBtn.name = DACHA;
			chaBtn.addEventListener(MouseEvent.CLICK, changePiZhuStyle);
		}
		/**
		 * 绘制撤销按钮
		 */
		private function drawCheXiao():void {
			cheXiaoBtn.graphics.lineStyle(2, LINECOLOR);
			cheXiaoBtn.graphics.beginFill(BACKCOLOR);
			cheXiaoBtn.graphics.drawRoundRect(0, 0, 20, 20, 10, 10);
			cheXiaoBtn.graphics.endFill();
			cheXiaoBtn.graphics.moveTo(5, 5);
			cheXiaoBtn.graphics.lineTo(8, 8);
			cheXiaoBtn.graphics.moveTo(5, 5);
			cheXiaoBtn.graphics.lineTo(8, 2);
			cheXiaoBtn.graphics.drawCircle(10, 10, 5);
			cheXiaoBtn.x = 55;
			cheXiaoBtn.y = 5;
			btnPanel.addChild(cheXiaoBtn);
			cheXiaoBtn.addEventListener(MouseEvent.CLICK, cheXiaoAction);
		}
		/**
		 * 绘制完成按钮
		 */
		private function drawWanCheng():void {
			wanChengBtn.graphics.lineStyle(2, LINECOLOR);
			wanChengBtn.graphics.beginFill(BACKCOLOR);
			wanChengBtn.graphics.drawRoundRect(0, 0, 20, 20, 10, 10);
			wanChengBtn.graphics.endFill();
			wanChengBtn.graphics.drawCircle(10, 10, 5);
			wanChengBtn.x = 80;
			wanChengBtn.y = 5;
			btnPanel.addChild(wanChengBtn);
			wanChengBtn.addEventListener(MouseEvent.CLICK, wanChen);
		}
		/**
		 * 绘制所有按钮
		 */
		private function drawBtns():void {
			drawGou();
			drawCha();
			drawWanCheng();
			drawCheXiao();
		}
		/**
		 * 是否注册批注样式
		 */
		private function isRegisted():Boolean {
			if (piZhuStyle == 0) 
				return false; 
			else
				return true;
		}
		/**
		 * 打钩
		 */
		private function daGou(x:int = 0,y:int = 0):void {
			canvas.graphics.lineStyle(1, LINECOLOR);
			canvas.graphics.moveTo(x - 10, y - 10);
			canvas.graphics.lineTo(x, y);
			canvas.graphics.lineTo(x + 20, y - 20);
			pictureContainer.addChild(canvas);
		}
		/**
		 * 打叉
		 */
		private function daCha(x:int = 0,y:int = 0):void {
			canvas.graphics.lineStyle(1, LINECOLOR);
			canvas.graphics.moveTo(x - 10, y - 10);
			canvas.graphics.lineTo(x + 10, y + 10);
			canvas.graphics.moveTo(x - 10, y + 10);
			canvas.graphics.lineTo(x + 10, y - 10);
			pictureContainer.addChild(canvas);
		}
		/**
		 * 单击的批注操作
		 */
		private function piZhuAction():void {
			var funcs:Array = ["", "daGou", "daCha"];
			var func:String = funcs[piZhuStyle];
			//if(evt.target == pictureContainer){
				//判断是否注册了批注样式
				if (isRegisted && func != "") {
					//this[func](mouseX,mouseY);
					//daGou();
					var commandData:CommandData = new CommandData(this[func], mouseX, mouseY);
					stackAction.push(commandData);
					commandData.func(commandData.x, commandData.y);
				}
			//}
		}
		/**
		 * 改变批注样式函数
		 */
		private function changePiZhuStyle(evt:MouseEvent):void {
			var btnName:String = evt.target.name;
			if (btnName == DAGOU)
				piZhuStyle = 1;
			else if(btnName == DACHA)
				piZhuStyle = 2;
			container.removeChild(btnPanel);
		}
		/**
		 * 输出图片
		 */
		private function toPic():void {
			var bmd:BitmapData = new BitmapData(bitmap.width + 10,bitmap.height + 10);
			bmd.draw(pictureContainer);
			var bm:Bitmap = new Bitmap(bmd);
			bm.x = 500;
			pictureContainer.addChild(bm);
			//TODO如何转换成base64？
			var encoder:PNGEncoder = new PNGEncoder();
			var bs:ByteArray = new ByteArray();
			bs = encoder.encode(bmd);
			var base64:Base64Encoder = new Base64Encoder();
			base64.encodeBytes(bs);
			var result:String = base64.toString();
			//成功trace
			//trace(result);
		}
		private function wanChen(evt:MouseEvent):void {
			toPic();
			container.removeChild(btnPanel);
			this.piZhuStyle = 0;
		}
		/**
		 * 撤销操作
		 */
		private function cheXiaoAction(evt:MouseEvent):void {
			if (stackAction) {
				stackAction.pop();
				canvas.graphics.clear();
				var index:int = stackAction.length;
				while (index > 0)
				{
					var commandData:CommandData = stackAction[index - 1];
					commandData.func(commandData.x, commandData.y);
					index--;
				}
			}
		}
		
	}
}