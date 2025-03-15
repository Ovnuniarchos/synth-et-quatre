using namespace godot;

void NodeLib::accumulate(Array input,Array output){
	for(int i=input.size()-1;i>=0;i--){
		double in=(double)input[i];
		if(!std::isnan(in)){
			double out=(double)output[i];
			output[i]=std::isnan(out)?in:(out+in);
		}
	}
}

void NodeLib::de_nan_ize(Array array,double value){
	for(int i=array.size()-1;i>=0;i--){
		if(std::isnan((double)array[i])){
			array[i]=value;
		}
	}
}

void NodeLib::optionize(Array array,double value,int option_count){
	I2DConverter i2d;
	double oc0=option_count;
	double oc1=option_count-1.0;
	for(int i=array.size()-1;i>=0;i--){
		i2d.d=(double)array[i];
		if(std::isnan(i2d.d)){
			array[i]=value;
		}else{
			array[i]=(int64_t)Math::clamp(i2d.setPositive()*oc0,0.0,oc1);
		}
	}
}

void NodeLib::booleanize(Array array){
	I2DConverter i2d;
	for(int i=array.size()-1;i>=0;i--){
		i2d.d=(double)array[i];
		if(!std::isnan(i2d.d)){
			array[i]=i2d.setPositive()>=0.5?1.0:0.0;
		}
	}
}

void NodeLib::diff_booleanize(Array array){
	I2DConverter i2d;
	for(int i=array.size()-1;i>=0;i--){
		i2d.d=(double)array[i];
		array[i]=Math::clamp(i2d.setPositive(),0.0,1.0);
	}
}

void NodeLib::clamp(Array array,double minval,double maxval){
	for(int i=array.size()-1;i>=0;i--){
		array[i]=Math::clamp((double)array[i],minval,maxval);
	}
}
