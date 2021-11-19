package main

import(
	"fmt"
	//"encoding/binary"
	"encoding/hex"
	"log"
	"strconv"
)

type TT2Decrypt struct{
	content   []byte
	list9c8   []byte
	list6b0   []int64
}

var bbs = [...]int64{
	0XF3BCC908, 0X6A09E667, 0X84CAA73B, 0XBB67AE85, 0XFE94F82B,
	0X3C6EF372, 0X5F1D36F1, 0XA54FF53A,
	0XADE682D1, 0X510E527F, 0X2B3E6C1F, 0X9B05688C, 0XFB41BD6B,
	0X1F83D9AB, 0X137E2179, 0X5BE0CD19}

//16进制解码
func HexDecode(s string) []byte {
    dst := make([]byte, hex.DecodedLen(len(s))) //申请一个切片, 指明大小. 必须使用hex.DecodedLen
    n, err := hex.Decode(dst,  []byte(s))//进制转换, src->dst
    if err != nil {
        log.Fatal(err)
        return nil
    }
    return dst[:n] //返回0:n的数据.
}
//字符串转为16进制
func HexEncode(s string) []byte {
    dst := make([]byte, hex.EncodedLen(len(s))) //申请一个切片, 指明大小. 必须使用hex.EncodedLen
    n := hex.Encode(dst, []byte(s)) //字节流转化成16进制
    return dst[:n]
}

func Hextob(str string)([]byte){//right function to acc
	slen:= len(str)
	bHex:= make([]byte, len(str)/2)
	ii:=0
	for i:=0; i<len(str);i=i+2{
		if slen!=1{
			ss:= string(str[i])+string(str[i+1])
			bt,_ := strconv.ParseInt(ss,16,32)
			bHex[ii] =byte(bt)
			ii = ii+1
			slen = slen-2;
		}
	}
	return bHex;
}

func ByteToLongArray(list_byte []byte)([]int){
	slen:= len(list_byte)
	bHex:= make([]int, slen)

	for i:=0; i<slen;i++{
		if(list_byte[i]<0){
			fmt.Println("line is ",list_byte[i])
			//bHex[i]= ((int)(list_byte[i])+256)
		}else{
			//bHex[i] = list_byte[i]
		}
	}
	return bHex
}

func convertZhengLong(bbs []int64)([]int64){

	return bbs

}

func check(value int64) (uint32){
	s:=""
	if(value<0){
		value+=0x100000000
		s=fmt.Sprintf("%x",value)
	}else{
		s=fmt.Sprintf("%x",value)
	}
	slen:= len(s)
	if(slen>8){
		size := slen-8
		s=s[size:]
	}

	fmt.Println("value is ",s,value)
	ru, _ := strconv.ParseUint(s, 16, 64)
	return uint32(ru)
}

func dump_list(content_list []int)([]int){
	size := len(content_list)
	ssize := int(size/4)
	var ret []int
	for i:=0;i<ssize;i++{
		tmpStr:=content_list[i*4]
		for k:=1;k<4;k++{
			tmpStr=tmpStr*256+content_list[i*4+k]
		}
		ret=append(ret, tmpStr)
	}
	return ret
}

func hex_list(hex_list[] int)([]int){
	/**/
	/*list to 16 byte int*
	/**/
	var ret []int
	var stmp string
	var tmp int
	size:= len(hex_list)
	for i:=0; i< size; i++{
		tmp = hex_list[i]
		stmp = fmt.Sprintf("%x",tmp)
		for{

			if(len(stmp)>=8){
				break
			}
			stmp="0"+stmp
		}
		for k:=0;k<8;k+=2{
			vv,_:= strconv.ParseInt(string(stmp[k])+string(stmp[k+1]),16,64)
			ret= append(ret, int(vv))
		}
	}
	return ret
}
func main() {
    s16 := "6769746875622e636f6d2f79657a696861636b"
    fmt.Println(string(HexDecode(s16)))

    //s := "github.com/yezihack"
    //fmt.Println(string(HexEncode(s)))
	//fmt.Println("byteArray: ", HexEncode(s))
	//r := fmt.Sprintf("%x", HexEncode(s))
    //fmt.Println("16byte is ",r)
	//fmt.Println("16r is ", Hextob(s16))
    //fmt.Println(hex.Dump([]byte(s)))

	//x:= ^uint32(0)
	//fmt.Println("uint32 is ....",x)

	//fmt.Println("other is 255..", ByteToLongArray(Hextob("ffffffffff")))
	//var i int16 = -7
	//var h, l uint8 = uint8(i>>8), uint8(i&0xff)
	//fmt.Println("l ,r ",h,l)
	//fmt.Println("print", bbs)
	//	fmt.Println("ok",strconv.ParseUint("89999999",16,64))

	fmt.Println("uint32", check(-0xf9999c9999))
args:=[]int{57, 101, 124, 196, 22, 156, 230, 8, 156, 23, 92, 92, 80, 129, 237, 15}
	fmt.Println("result: ",dump_list(args) )
args2:=[]int{962952388, 379381256, 2618776668, 1350692111}
	fmt.Println("hex : ", hex_list(args2))
}

/*func main(){
	var i int64=2424
	buf:= Int64ToBytes()

}

func Int64ToBytes(i int64)[] byte{
	var buf = make([] byte, 8)
	//binary.BigEndian.PutUint64(buf, uint64(i))
	reutrn buf
}
*/
