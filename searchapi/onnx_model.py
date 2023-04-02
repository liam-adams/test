import onnxruntime as rt


class SklearnOnnx:
    def __init__(self, model_loc):
        self.model = rt.InferenceSession(model_loc)

    def predict(self, query,topk=10):#
        inputs = {'input': [[query]]}
        pred_onnx = self.model.run(None, inputs)
        pred_onnx_proba_dict = pred_onnx[1][0]
        sorted_pred_onnx_proba_dict = sorted(pred_onnx_proba_dict.items(),key=lambda x:x[1],reverse=True)
        cats = [i[0] for i in sorted_pred_onnx_proba_dict[:topk]]
        proba = [i[1] for i in sorted_pred_onnx_proba_dict[:topk]]
        
        return cats,proba
            
