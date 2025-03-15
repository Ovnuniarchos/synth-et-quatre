using namespace godot;

void NodeLib::clip(Array output,int segment_size,int outptr,Array input){
	int size_mask=output.size()-1;
	for(;segment_size;segment_size--){
		output[outptr]=input[outptr];
		outptr=(outptr+1)&size_mask;
	}
}