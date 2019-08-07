# openvino-tf-to-ir

[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/KnightWhoSayNi/openvino-tf-to-ir/blob/master/LICENSE)

Dockerfile for converting a frozen Tensorflow model to OpenVINO™ *Intermediate Representation* (IR) using *Model Optimizer* (MO)

## Content

This Dockerfile is based on [docker-openvino-linux](https://github.com/KnightWhoSayNi/docker-openvino-linux/blob/master/README.md)

## Prerequisites

Place a frozen Tensorflow model into *frozen_tf_model* folder and then zip it as *frozen_tf_model.zip*.

```shell
tree frozen_tf_model

    frozen_tf_model
    ├── checkpoint
    ├── frozen_inference_graph.pb
    ├── model.ckpt.data-00000-of-00001
    ├── model.ckpt.index
    ├── model.ckpt.meta
    ├── pipeline.config
    └── saved_model
        ├── saved_model.pb
        └── variables

zip -r frozen_tf_model.zip frozen_tf_model/*
```

## Usage

Supported arguments with **default values**:
- data_type **FP16** [FP16 is used by *Intel® Movidius™ Neural Compute Stick 2*]
- log_level **ERROR**
- model_name **tf_model_converted_into_ir**
- input_model **frozen_inference_graph.pb**
- tensorflow_object_detection_api_pipeline_config
- tensorflow_use_custom_operations_config
- scale
- input_shape
- batch


Provide your arguments as a `--build-arg`. For instance:

```shell
docker build --build-arg scale=127.5 --build-arg build_level=DEBUG --build-arg data_type=FP32 -t tf-to-ir-image .
```

Get IR files

```shell
docker run -d --name tf-to-ir-container tf-to-ir-image
mkdir -p openvino_ir_files
docker cp -a tf-to-ir-container:/tmp/ir_files.zip openvino_ir_files
docker stop tf-to-ir-container
docker rm tf-to-ir-container
```

## Example

Convert a **SSD MobileNet v1** Tensorflow model to IR using MO

```shell
wget -O frozen_tf_model.tar.gz http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v1_coco_2018_01_28.tar.gz
tar -zxvf frozen_tf_model.tar.gz -C frozen_tf_model --strip-components=1 && zip -r frozen_tf_model.zip frozen_tf_model/* && rm frozen_tf_model.tar.gz
docker build --build-arg scale=127.5 --build-arg data_type=FP16 --build-arg  tensorflow_use_custom_operations_config=/opt/intel/openvino/deployment_tools/model_optimizer/extensions/front/tf/ssd_support_api_v1.14.json --build-arg tensorflow_object_detection_api_pipeline_config=/tmp/frozen_tf_model/pipeline.config --build-arg model_name=ssd_mobilenet_v1 -t tf-to-ir-image .
docker run -d --name tf-to-ir-container tf-to-ir-image
mkdir -p openvino_ir_files
docker cp -a tf-to-ir-container:/tmp/ir_files.zip openvino_ir_files
docker stop tf-to-ir-container
docker rm tf-to-ir-container
```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

[Intel® OpenVINO™](https://software.intel.com/en-us/openvino-toolkit) - [https://docs.openvinotoolkit.org/latest/_docs_MO_DG_prepare_model_convert_model_Convert_Model_From_TensorFlow.html](https://docs.openvinotoolkit.org/latest/_docs_MO_DG_prepare_model_convert_model_Convert_Model_From_TensorFlow.html)
