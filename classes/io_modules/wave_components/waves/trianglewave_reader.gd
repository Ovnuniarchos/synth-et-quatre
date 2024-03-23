extends WaveComponentIO
class_name TriangleWaveReader


const HALVES_2_QUARTERS:Array=[
	[TriangleWave.QUARTER.Q0,TriangleWave.QUARTER.Q1],
	[TriangleWave.QUARTER.Q2,TriangleWave.QUARTER.Q3],
	[TriangleWave.QUARTER.QZ,TriangleWave.QUARTER.QZ],
	[TriangleWave.QUARTER.QH,TriangleWave.QUARTER.QH],
	[TriangleWave.QUARTER.QL,TriangleWave.QUARTER.QL],
]


func _init(wc:Array).(wc)->void:
	pass


func deserialize(inf:ChunkedFile,header:Dictionary)->FileResult:
	if not inf.is_chunk_valid(header,TRIANGLE_ID,TRIANGLE_VERSION):
		return FileResult.new(FileResult.ERR_INVALID_CHUNK,{
			FileResult.ERRV_CHUNK:inf.get_chunk_id(header),
			FileResult.ERRV_VERSION:inf.get_chunk_version(header),
			FileResult.ERRV_EXP_CHUNK:TRIANGLE_ID,
			FileResult.ERRV_EXP_VERSION:TRIANGLE_VERSION,
			FileResult.ERRV_FILE:inf.get_path()
		})
	var version:int=header[ChunkedFile.CHUNK_VERSION]
	var w:TriangleWave=TriangleWave.new()
	_deserialize_start(inf,w,version)
	w.freq_mult=inf.get_float()
	w.phi0=inf.get_float()
	if version>=1:
		w.quarters[0]=inf.get_8()
		w.quarters[1]=inf.get_8()
		w.quarters[2]=inf.get_8()
		w.quarters[3]=inf.get_8()
	else:
		var h:int=inf.get_8()
		w.quarters[0]=HALVES_2_QUARTERS[h][0]
		w.quarters[1]=HALVES_2_QUARTERS[h][1]
		h=inf.get_8()
		w.quarters[2]=HALVES_2_QUARTERS[h][0]
		w.quarters[3]=HALVES_2_QUARTERS[h][1]
	w.cycles=inf.get_float()
	w.pos0=inf.get_float()
	w.pm=inf.get_float()
	if version>=1:
		w.power=inf.get_float()
		w.decay=inf.get_float()
	if inf.get_error():
		return FileResult.new(inf.get_error(),{FileResult.ERRV_FILE:inf.get_path()})
	return FileResult.new(OK,w)
