FROM threeheadedknight/docker-openvino-linux:latest
MAINTAINER KnightWhoSayNi <threeheadedknight@protonmail.com>

WORKDIR /tmp

RUN mkdir -p /tmp/ir_files

COPY frozen_tf_model.zip /tmp
RUN unzip frozen_tf_model.zip && \
    tree tmp/frozen_tf_model

ARG data_type=FP16
ARG log_level=ERROR
ARG model_name=tf_model_converted_into_ir
ARG input_model=frozen_inference_graph.pb
ARG tensorflow_object_detection_api_pipeline_config=""
ARG tensorflow_use_custom_operations_config=""
ARG scale=""
ARG input_shape=""
ARG batch=""

# BugFix in ssd_support_api_v1.14.json file -> "Postprocessor/Cast_1" instead of "Postprocessor/Cast" [source] https://software.intel.com/en-us/forums/computer-vision/topic/815126
RUN sed -i 's/Postprocessor\/Cast/Postprocessor\/Cast_1/g' /opt/intel/openvino/deployment_tools/model_optimizer/extensions/front/tf/ssd_support_api_v1.14.json

RUN tree /tmp/frozen_tf_model

RUN if [ -n "$scale" ] ; then export scale="--scale ${scale}" ; fi && \
    if [ -n "$input_shape" ] ; then export input_shape="--input_shape=${input_shape}" ; fi && \
    if [ -n "$batch" ] ; then export batch="--batch=${batch}" ; fi && \
    if [ -n "$tensorflow_use_custom_operations_config" ] ; then export tucoc="--tensorflow_use_custom_operations_config=${tensorflow_use_custom_operations_config}"; fi && \
    if [ -n "$tensorflow_object_detection_api_pipeline_config" ] ; then export todapc="--tensorflow_object_detection_api_pipeline_config=${tensorflow_object_detection_api_pipeline_config}" ; fi && \
    cd /opt/intel/openvino/deployment_tools/model_optimizer && \
    python3 mo_tf.py \
    --input_model=/tmp/frozen_tf_model/${input_model} \
    --model_name ${model_name} \
    --output_dir /tmp/ir_files \
    --data_type ${data_type} \
    --log_level ${log_level} \
    --reverse_input_channels \
    ${scale} \
    ${input_shape} \
    ${batch} \
    ${tucoc} \
    ${todapc}

RUN tree /tmp/ir_files && \
    zip -r ir_files.zip ir_files/*
