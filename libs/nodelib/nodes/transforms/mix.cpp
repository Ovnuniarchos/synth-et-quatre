using namespace godot;

void NodeLib::mix(Array output,int segment_size,int outptr,
	Array a,Array b,Array op,
	Array mix,Array clamp_mix,Array isolate,
	Array power,Array decay,Array dc
){
	enum {
		MIX_MIX,MIX_ADD,MIX_SUB,MIX_MUL,MIX_DIV,MIX_MOD,MIX_FMOD,
		MIX_POWER,MIX_MAX,MIX_MIN,MIX_GT,MIX_GE,MIX_LT,MIX_LE,
		MIX_CMP,MIX_SIGN_CP,MIX_OVER,MIX_UNDER
	};

	int size_mask=output.size()-1;
	double mix_value;
	double a_in,b_in;
	I2DConverter i2d;
	Decay decayer(segment_size);
	for(int i=segment_size;i;i--){
		mix_value=Math::lerp((double)mix[outptr],Math::clamp((double)mix[outptr],-1.0,1.0),(double)clamp_mix[outptr]);
		a_in=std::isnan((double)a[outptr])?(double)b[outptr]:(double)a[outptr];
		b_in=std::isnan((double)b[outptr])?(double)a[outptr]:(double)b[outptr];
		switch((int)op[outptr]){
			case MIX_MIX:
				i2d.d=(a_in+b_in)*0.5;
				break;
			case MIX_ADD:
				i2d.d=a_in+b_in;
				break;
			case MIX_SUB:
				i2d.d=a_in-b_in;
				break;
			case MIX_MUL:
				i2d.d=a_in*b_in;
				break;
			case MIX_DIV:
				i2d.d=b_in!=0.0?(a_in/b_in):0.0;
				break;
			case MIX_MOD:
				i2d.d=b_in!=0.0?Math::fmod(a_in,b_in):0.0;
				break;
			case MIX_FMOD:
				i2d.d=b_in!=0.0?fposmod(a_in,b_in):0.0;
				break;
			case MIX_POWER:
				i2d.d=a_in;
				i2d.abspow(b_in);
				break;
			case MIX_MAX:
				i2d.d=a_in>b_in?a_in:b_in;
				break;
			case MIX_MIN:
				i2d.d=a_in<b_in?a_in:b_in;
				break;
			case MIX_GT:
				i2d.d=a_in>b_in?1.0:0.0;
				break;
			case MIX_GE:
				i2d.d=a_in>=b_in?1.0:0.0;
				break;
			case MIX_LT:
				i2d.d=a_in<b_in?1.0:0.0;
				break;
			case MIX_LE:
				i2d.d=a_in<=b_in?1.0:0.0;
				break;
			case MIX_CMP:
				i2d.d=sgn(a_in-b_in);
				break;
			case MIX_SIGN_CP:
				i2d.d=a_in;
				i2d.setSign(b_in);
				break;
			case MIX_OVER:
				i2d.d=std::isnan(a_in)?a_in:b_in;
				break;
			case MIX_UNDER:
				i2d.d=std::isnan(b_in)?a_in:b_in;
				break;
		}
		i2d.d=mix_value>0.0?Math::lerp(i2d.d,b_in,mix_value):Math::lerp(i2d.d,a_in,-mix_value);
		output[outptr]=decayer.next(i2d.abspow((double)power[outptr]),(double)decay[outptr])+(double)dc[outptr];
		outptr=(outptr+1)&size_mask;
	}
	fill_out_of_region(segment_size,outptr,output,a,isolate);
}