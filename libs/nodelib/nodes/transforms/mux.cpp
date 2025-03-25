using namespace godot;

void NodeLib::mux(Array output,int segment_size,int outptr,
	Array inputs,Array selector,Array clip
){
	enum{MUX_CLAMP,MUX_WRAP};
	int size_mask=output.size()-1;
	double max_op=inputs.size()-1.0;
	double half_ops=inputs.size()*0.5;
	double sel;
	for(;segment_size;segment_size--){
		if ((int)clip[outptr]==MUX_WRAP){
			sel=Math::wrapf((double)selector[outptr],-1.0,1.0);
		}else{
			sel=Math::clamp((double)selector[outptr],-1.0,1.0);
		}
		sel=Math::clamp((sel+1.0)*half_ops,0.0,max_op);
		output[outptr]=(double)((Array)inputs[sel])[outptr];
		outptr=(outptr+1)&size_mask;
	}
}