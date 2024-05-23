import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image, CompressedImage
from cv_bridge import CvBridge
import cv2

class CompressedImagePublisher(Node):
    def __init__(self):
        super().__init__('compressed_image_publisher')

        # Initialize CV Bridge
        self.bridge = CvBridge()

        # Create a subscriber for the raw images
        self.subscription = self.create_subscription(
            Image,
            '/camera/color/image_raw',
            self.image_callback,
            10
        )

        # Create a publisher for the compressed images
        self.publisher = self.create_publisher(
            CompressedImage,
            '/image_compressed',
            10
        )

        # Create a parameter for controlling the publish frequency
        self.declare_parameter('publish_frequency', 10.0)
        self.timer = self.create_timer(1.0 / self.get_parameter('publish_frequency').value, self.timer_callback)

        self.latest_image = None

    def image_callback(self, msg):
        # Store the latest image
        self.latest_image = msg

    def timer_callback(self):
        # Check if there is a new image to publish
        if self.latest_image:
            # Convert the ROS Image message to OpenCV format
            cv_image = self.bridge.imgmsg_to_cv2(self.latest_image, 'bgr8')

            # Compress the image
            compressed_image_msg = CompressedImage()
            compressed_image_msg.header = self.latest_image.header
            compressed_image_msg.format = 'jpeg'
            compressed_image_msg.data = cv2.imencode('.jpg', cv_image)[1].tostring()

            # Publish the compressed image
            self.publisher.publish(compressed_image_msg)

            # Reset the latest image
            self.latest_image = None

def main(args=None):
    rclpy.init(args=args)
    node = CompressedImagePublisher()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
